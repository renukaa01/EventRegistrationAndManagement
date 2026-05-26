package com.event.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import com.event.util.DBConnection;
import com.event.model.User;

public class ReportEventServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        User user = (User) session.getAttribute("user");
        String eventIdStr = request.getParameter("eventId");

        if (eventIdStr != null) {
            int eventId = Integer.parseInt(eventIdStr);
            try (Connection con = DBConnection.getConnection()) {
                
                // 1. Check if user already reported
                String checkSql = "SELECT id FROM reports WHERE user_id=? AND event_id=?";
                PreparedStatement chk = con.prepareStatement(checkSql);
                chk.setInt(1, user.getId());
                chk.setInt(2, eventId);
                ResultSet rs = chk.executeQuery();
                
                if (rs.next()) {
                    response.sendRedirect(request.getContextPath() + "/view-events?error=You+already+reported+this+event");
                    return;
                }

                // 2. Insert Report
                String insSql = "INSERT INTO reports (user_id, event_id, reason) VALUES (?, ?, 'User Flagged via UI')";
                PreparedStatement insPs = con.prepareStatement(insSql);
                insPs.setInt(1, user.getId());
                insPs.setInt(2, eventId);
                insPs.executeUpdate();

                // 3. Increment Event report_count
                String incSql = "UPDATE events SET report_count = report_count + 1 WHERE id=?";
                PreparedStatement incPs = con.prepareStatement(incSql);
                incPs.setInt(1, eventId);
                incPs.executeUpdate();

                // 4. Check if we need to auto-hide
                String countSql = "SELECT report_count FROM events WHERE id=?";
                PreparedStatement countPs = con.prepareStatement(countSql);
                countPs.setInt(1, eventId);
                ResultSet countRs = countPs.executeQuery();
                if (countRs.next()) {
                    int c = countRs.getInt("report_count");
                    if (c >= 3) {
                        String hideSql = "UPDATE events SET status='HIDDEN' WHERE id=?";
                        PreparedStatement hidePs = con.prepareStatement(hideSql);
                        hidePs.setInt(1, eventId);
                        hidePs.executeUpdate();
                    }
                }
                
                response.sendRedirect(request.getContextPath() + "/view-events?success=Event+Reported+Successfully");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/view-events?error=Failed+to+report+event");
            }
        }
    }
}