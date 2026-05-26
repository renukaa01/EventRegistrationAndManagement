package com.event.controller;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import com.event.model.Event;
import com.event.model.Team;
import com.event.model.User;
import com.event.dao.EventDAO;
import com.event.dao.TeamDAO;
import com.event.service.EventService;

@WebServlet("/process-registration")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ProcessRegistrationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String context = request.getContextPath();
        
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr == null) {
            response.sendRedirect(context + "/view-events?error=Invalid+Event");
            return;
        }

        int eventId = Integer.parseInt(eventIdStr);
        String customAnswers = request.getParameter("custom_answers");
        
        EventDAO eventDAO = new EventDAO();
        TeamDAO teamDAO = new TeamDAO();
        EventService eventService = new EventService();

        try {
            Event e = eventDAO.getEventById(eventId);
            if (e == null) throw new Exception("Event not found");

            // 1. Handle Payment File Upload
            String paymentPath = null;
            if ("PAID".equals(e.getParticipationMode())) {
                Part filePart = request.getPart("payment_screenshot");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = UUID.randomUUID().toString() + "-" + getFileName(filePart);
                    // Save to local upload directory within tomcat
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdir();
                    
                    filePart.write(uploadPath + File.separator + fileName);
                    paymentPath = "uploads/" + fileName;
                }
            }

            // 2. Handle Team Logic
            Integer teamId = null;
            if ("TEAM".equals(e.getEventType())) {
                String existingTeamIdStr = request.getParameter("existing_team_id");
                
                if (existingTeamIdStr != null && !existingTeamIdStr.trim().isEmpty()) {
                    teamId = Integer.parseInt(existingTeamIdStr);
                    // Constraint: Check Max size
                    java.sql.Connection con = com.event.util.DBConnection.getConnection();
                    java.sql.PreparedStatement teamPs = con.prepareStatement("SELECT COUNT(*) FROM registrations WHERE team_id=?");
                    teamPs.setInt(1, teamId);
                    java.sql.ResultSet teamRs = teamPs.executeQuery();
                    if (teamRs.next() && teamRs.getInt(1) >= e.getMaxTeamSize()) {
                        response.sendRedirect(context + "/view-events?error=Team+Max+Capacity+Reached");
                        return;
                    }
                    con.close();
                } else {
                    String teamName = request.getParameter("team_name");
                    if (teamName == null || teamName.trim().isEmpty()) {
                        response.sendRedirect(context + "/view-events?error=Team+Name+Required");
                        return;
                    }
                    Team team = new Team();
                    team.setName(teamName);
                    team.setEventId(eventId);
                    team.setLeaderUserId(user.getId());
                    
                    teamId = teamDAO.createTeam(team);
                    
                    if (teamId == null || teamId == -1) {
                        response.sendRedirect(context + "/view-events?error=Team+Name+already+exists");
                        return;
                    }
                }
            }

            // 3. Complete complex registration via service delegation
            String result = eventDAO.registerWithAdvancedPayload(user.getId(), eventId, teamId, customAnswers, paymentPath);

            if ("SUCCESS".equals(result)) {
                // If there's capacity, standard logic: we decrement capacity. 
                // Since dao bypasses standard logic here, decrement capacity manually in dao logic
                response.sendRedirect(context + "/my-events?success=Registration+Finalized+Successfully");
            } else if ("WAITLIST".equals(result)) {
                response.sendRedirect(context + "/my-events?success=Event+Full:+Added+to+Waitlist");
            } else {
                response.sendRedirect(context + "/view-events?error=Registration+Failed:+You+may+already+be+registered");
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendRedirect(context + "/view-events?error=Server+Exception+during+Registration");
        }
    }

    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "unknown.jpg";
    }
}
