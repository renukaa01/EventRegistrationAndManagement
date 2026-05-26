<%@ page import="java.util.List, com.event.model.Ticket, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
    String success = (String) session.getAttribute("adminSuccess");
    String error = (String) session.getAttribute("adminError");
    if (success != null) session.removeAttribute("adminSuccess");
    if (error != null) session.removeAttribute("adminError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Event Check-In Terminal</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f8f9fa; color: #1f2937; padding: 40px; }
        .container { max-width: 1000px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .btn-back { padding: 10px 20px; background: #e5e7eb; color: #374151; text-decoration: none; border-radius: 5px; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; background: #fff; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border-radius: 8px; overflow: hidden; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #e5e7eb; }
        th { background: #f9fafb; font-weight: bold; color: #4b5563; font-size: 14px; text-transform: uppercase; }
        .tkt-id { font-family: monospace; font-weight: bold; color: #3b82f6; }
        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; display:inline-block;}
        .status-active { background: #d1fae5; color: #065f46; }
        .status-used { background: #f3f4f6; color: #6b7280; }
        .status-cancelled { background: #fee2e2; color: #991b1b; }
        .btn-checkin { padding: 8px 15px; background: #10b981; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
        .btn-checkin:hover { background: #059669; }
        .btn-checkin:disabled { background: #d1d5db; cursor: not-allowed; }
        .empty { text-align: center; color: #6b7280; margin-top: 50px; }
        .msg-success { padding: 15px; background: #d1fae5; color: #065f46; border-radius: 5px; margin-bottom: 20px; text-align: center; }
        .msg-error { padding: 15px; background: #fee2e2; color: #991b1b; border-radius: 5px; margin-bottom: 20px; text-align: center; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🎟️ Event Check-In Terminal</h2>
            <a href="<%= request.getContextPath() %>/manage-events" class="btn-back">← Back to Dashboard</a>
        </div>

        <% if (success != null) { %><div class="msg-success"><%= success %></div><% } %>
        <% if (error != null) { %><div class="msg-error"><%= error %></div><% } %>

        <% if (tickets == null || tickets.isEmpty()) { %>
            <div class="empty"><h3>No tickets found for this event!</h3></div>
        <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>Ticket ID</th>
                        <th>Type</th>
                        <th>Holder Name</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Ticket t : tickets) { 
                        boolean isActive = "ACTIVE".equals(t.getStatus());
                    %>
                        <tr>
                            <td class="tkt-id"><%= t.getId() %></td>
                            <td><strong><%= t.getTicketType() %></strong></td>
                            <td>
                                <% if ("TEAM".equals(t.getTicketType())) { %>
                                    🏆 <%= t.getTeamName() %> (Team)
                                <% } else { %>
                                    👤 <%= t.getUserName() %>
                                <% } %>
                            </td>
                            <td>
                                <span class="status-badge 
                                    <%= isActive ? "status-active" : 
                                        "USED".equals(t.getStatus()) ? "status-used" : "status-cancelled" %>">
                                    <%= t.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <% if (isActive) { %>
                                    <form action="<%= request.getContextPath() %>/event-checkin" method="post" style="display:inline;">
                                        <input type="hidden" name="ticketId" value="<%= t.getId() %>">
                                        <input type="hidden" name="eventId" value="<%= request.getAttribute("eventId") %>">
                                        <button type="submit" class="btn-checkin" onclick="return confirm('Check-in this ticket? Cannot be undone.');">Scan In</button>
                                    </form>
                                <% } else { %>
                                    <button class="btn-checkin" disabled>Completed</button>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        <% } %>
    </div>
</body>
</html>
