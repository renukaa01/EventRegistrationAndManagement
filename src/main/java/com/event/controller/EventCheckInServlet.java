package com.event.controller;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.event.model.Ticket;
import com.event.model.User;
import com.event.service.EventService;
import com.event.service.OrganizationService;

public class EventCheckInServlet extends HttpServlet {
    private EventService eventService = new EventService();
    private OrganizationService orgService = new OrganizationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        Integer orgId = orgService.getOrgByAdmin(user.getId());
        if (orgId == null) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String eventIdStr = request.getParameter("eventId");
        if(eventIdStr != null) {
             int eventId = Integer.parseInt(eventIdStr);
             List<Ticket> tickets = eventService.getTicketsByEvent(eventId);
             request.setAttribute("tickets", tickets);
             request.setAttribute("eventId", eventId);
             request.getRequestDispatcher("/jsp/event-checkin.jsp").forward(request, response);
             return;
        }
        response.sendRedirect(request.getContextPath() + "/manage-events");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
            return;
        }

        String ticketId = request.getParameter("ticketId");
        String eventIdStr = request.getParameter("eventId");

        if (ticketId != null && !ticketId.trim().isEmpty()) {
            boolean success = eventService.markTicketUsed(ticketId);
            if (success) {
                session.setAttribute("adminSuccess", "Ticket successfully marked as USED. Guests checked in.");
            } else {
                session.setAttribute("adminError", "Failed to mark ticket. It might already be used or cancelled.");
            }
        }
        
        response.sendRedirect(request.getContextPath() + "/event-checkin?eventId=" + eventIdStr);
    }
}
