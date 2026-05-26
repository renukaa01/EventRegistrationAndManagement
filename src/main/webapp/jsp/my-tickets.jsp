<%@ page import="java.util.List, com.event.model.Ticket, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Ticket> tickets = (List<Ticket>) request.getAttribute("tickets");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Tickets</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f3f4f6; color: #1f2937; padding: 40px; }
        .container { max-width: 900px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .btn-back { padding: 10px 20px; background: #e5e7eb; color: #374151; text-decoration: none; border-radius: 5px; font-weight: bold; }
        .ticket-list { display: flex; flex-direction: column; gap: 20px; }
        .ticket-wrapper { background: #fff; border-radius: 12px; display: flex; box-shadow: 0 4px 6px rgba(0,0,0,0.05); overflow: hidden; border: 1px solid #e5e7eb;}
        .ticket-side { background: #1f2937; color: white; width: 140px; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 20px; border-right: 2px dashed #9ca3af; position: relative;}
        .ticket-side::before, .ticket-side::after { content: ''; position: absolute; width: 30px; height: 30px; background: #f3f4f6; border-radius: 50%; right: -16px; }
        .ticket-side::before { top: -15px; }
        .ticket-side::after { bottom: -15px; }
        .ticket-type { font-size: 14px; font-weight: bold; letter-spacing: 2px; text-transform: uppercase; writing-mode: vertical-rl; transform: rotate(180deg); opacity: 0.8;}
        .ticket-main { padding: 25px; flex: 1; display:flex; flex-direction: column; justify-content:space-between;}
        .top-row { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px;}
        .event-title { font-size: 24px; font-weight: bold; color: #111827; }
        .event-date { font-size: 14px; color: #6b7280; font-weight: bold;}
        .tkt-id { font-size: 28px; font-family: monospace; font-weight: bold; color: #3b82f6; background: #eff6ff; padding: 5px 15px; border-radius: 4px; display:inline-block; border: 1px solid #bfdbfe;}
        .status-badge { padding: 6px 12px; border-radius: 20px; font-size: 13px; font-weight: bold; }
        .status-active { background: #d1fae5; color: #065f46; }
        .status-used { background: #f3f4f6; color: #6b7280; }
        .status-cancelled { background: #fee2e2; color: #991b1b; }
        .empty { text-align: center; color: #6b7280; padding: 50px; background: #fff; border-radius: 8px; border: 1px dashed #d1d5db;}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🎟️ My Tickets Wallet</h2>
            <a href="<%= request.getContextPath() %>/home" class="btn-back">← Back to Dashboard</a>
        </div>

        <% if (tickets == null || tickets.isEmpty()) { %>
            <div class="empty">
                <h3>Your wallet is empty!</h3>
                <p style="margin-top:10px;">Check out the Events page to register for upcoming shows, or wait for your paid registrations to be approved.</p>
                <a href="<%= request.getContextPath() %>/view-events" style="display:inline-block; margin-top:20px; padding:10px 20px; background:#10b981; color:#fff; text-decoration:none; border-radius:5px; font-weight:bold;">Find Events</a>
            </div>
        <% } else { %>
            <div class="ticket-list">
                <% for (Ticket t : tickets) { %>
                    <div class="ticket-wrapper">
                        <div class="ticket-side">
                            <div class="ticket-type"><%= t.getTicketType() %> ENTRY</div>
                        </div>
                        <div class="ticket-main">
                            <div class="top-row">
                                <div>
                                    <h3 class="event-title"><%= t.getEventTitle() %></h3>
                                    <span class="event-date">📅 <%= t.getEventDate() %></span>
                                </div>
                                <span class="status-badge 
                                    <%= "ACTIVE".equals(t.getStatus()) ? "status-active" : 
                                        "USED".equals(t.getStatus()) ? "status-used" : "status-cancelled" %>">
                                    <%= t.getStatus() %>
                                </span>
                            </div>
                            <div style="margin-top: 10px;">
                                <div style="font-size: 12px; color: #6b7280; margin-bottom: 4px; text-transform: uppercase;">Unique Ticket ID</div>
                                <div class="tkt-id"><%= t.getId() %></div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
