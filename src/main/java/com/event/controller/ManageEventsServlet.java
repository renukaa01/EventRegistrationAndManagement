package com.event.controller;

import java.io.IOException;
import java.util.List;

import jakarta.servlet.*;
import jakarta.servlet.http.*;

import com.event.model.*;
import com.event.service.*;

public class ManageEventsServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        String context = request.getContextPath();

        if (user == null) {
            response.sendRedirect(context + "/jsp/login.jsp");
            return;
        }

        OrganizationService orgService = new OrganizationService();
        Integer orgId = orgService.getOrgByAdmin(user.getId());

        if (orgId == null) {
            // Not an organizer
            response.sendRedirect(context + "/home");
            return;
        }

        EventService eventService = new EventService();
        List<Event> orgEvents = eventService.getEventsByOrganization(orgId);

        // Fetch Analytics
        java.util.Map<Integer, Double> revenueMap = new java.util.HashMap<>();
        java.util.Map<Integer, Integer> waitlistMap = new java.util.HashMap<>();
        int totalNetworkSeats = 0;
        int totalWaitlistNetwork = 0;
        int totalEvents = orgEvents.size();

        for (Event e : orgEvents) {
            totalNetworkSeats += e.getAvailableSeats();
            
            if ("PAID".equals(e.getEventType())) {
                revenueMap.put(e.getId(), eventService.getEventRevenue(e.getId()));
            }

            // Get waitlist count for each event
            int waitCount = 0;
            try (java.sql.Connection con = com.event.util.DBConnection.getConnection()) {
                java.sql.PreparedStatement wps = con.prepareStatement("SELECT COUNT(*) FROM waitlist WHERE event_id=?");
                wps.setInt(1, e.getId());
                java.sql.ResultSet wrs = wps.executeQuery();
                if (wrs.next()) {
                    waitCount = wrs.getInt(1);
                    totalWaitlistNetwork += waitCount;
                }
            } catch (Exception ex) { ex.printStackTrace(); }
            
            waitlistMap.put(e.getId(), waitCount);
        }

        request.setAttribute("orgEvents", orgEvents);
        request.setAttribute("revenueMap", revenueMap);
        request.setAttribute("waitlistMap", waitlistMap);
        request.setAttribute("totalNetworkSeats", totalNetworkSeats);
        request.setAttribute("totalWaitlistNetwork", totalWaitlistNetwork);
        request.setAttribute("totalEvents", totalEvents);

        request.setAttribute("orgEvents", orgEvents);
        request.setAttribute("revenueMap", revenueMap);
        request.getRequestDispatcher("/jsp/manage-events.jsp").forward(request, response);
    }
}
