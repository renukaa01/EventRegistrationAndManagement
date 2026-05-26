<%@ page import="java.util.*, com.event.model.Event" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> list = (List<Event>) request.getAttribute("orgEvents");
Map<Integer, Double> revenueMap = (Map<Integer, Double>) request.getAttribute("revenueMap");
String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Manage Events</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; }

        .navbar { background-color: #ffffff; padding: 15px 30px; border-bottom: 2px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 22px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .nav-links a { color: #4b5563; text-decoration: none; font-weight: bold; font-size: 15px; margin-left: 20px;}
        .nav-links a:hover { color: #e15a42; }

        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
        
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #e5e7eb; padding-bottom: 20px;}
        .header h2 { font-size: 28px; color: #1f2937; }

        .msg-success { background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; font-size: 14px; padding: 12px; border-radius: 5px; margin-bottom: 20px; text-align: center; }

        .btn-create { display: inline-block; padding: 10px 20px; background-color: #e15a42; color: #ffffff; border-radius: 5px; font-weight: bold; text-decoration: none; font-size: 14px; }
        .btn-create:hover { background-color: #c84630; }

        .event-card { background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 30px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 20px; }
        .card-header h3 { font-size: 22px; color: #1f2937; margin-bottom: 10px;}
        
        .badge { display: inline-block; padding: 4px 10px; border-radius: 3px; font-size: 12px; font-weight: bold; color: #ffffff; }
        .badge-active { background-color: #10b981; }
        .badge-hidden { background-color: #ef4444; }

        .grid-container { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        
        .details-section p { font-size: 14px; color: #4b5563; margin-bottom: 8px; }
        .details-section strong { font-weight: bold; color: #1f2937; width: 80px; display: inline-block;}
        
        .stats-section { background-color: #f3f4f6; padding: 15px; border-radius: 5px; }
        .stats-row { display: flex; justify-content: space-between; margin-bottom: 10px; font-size: 14px; border-bottom: 1px solid #e5e7eb; padding-bottom: 8px;}
        .stats-row:last-child { border-bottom: none; }
        .stats-title { color: #4b5563; font-weight: bold;}
        .stats-value { font-weight: bold; color: #1f2937; }

        .actions { margin-top: 25px; border-top: 1px solid #e5e7eb; padding-top: 20px; display: flex; justify-content: space-between; align-items: center;}
        
        .btn-toggle { padding: 10px 15px; border: none; border-radius: 5px; font-size: 14px; font-weight: bold; cursor: pointer; color: #ffffff; }
        .btn-hide { background-color: #1f2937; }
        .btn-publish { background-color: #3b82f6; }

        .btn-export { display: inline-block; padding: 10px 15px; background-color: #f59e0b; color: #ffffff; text-decoration: none; border-radius: 5px; font-size: 14px; font-weight: bold; }
        .btn-export:hover { background-color: #d97706; }
        
        .empty { text-align: center; background: #ffffff; padding: 50px; border: 1px solid #e5e7eb; border-radius: 8px; color: #6b7280; font-size: 16px;}
    </style>
</head>
<body>

    <div class="navbar">
        <a href="<%= request.getContextPath() %>" class="logo">Event Management</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home">Dashboard</a>
        </div>
    </div>

    <div class="container">
        <div class="header">
            <h2>Manage Events</h2>
            <div style="display:flex; gap:10px;">
                <a href="<%= request.getContextPath() %>/verify-payments" class="btn-create" style="background:#eab308;">Review Pending Payments</a>
                <a href="<%= request.getContextPath() %>/jsp/add-event.jsp" class="btn-create">Create New Event</a>
            </div>
        </div>

        <% if (success != null) { %><div class="msg-success"><%= success %></div><% } %>

        <!-- TELEMETRY DASHBOARD -->
        <%
            Integer totalEvents = (Integer) request.getAttribute("totalEvents");
            Integer totalSeats = (Integer) request.getAttribute("totalNetworkSeats");
            Integer totalWait = (Integer) request.getAttribute("totalWaitlistNetwork");
            Map<Integer, Integer> waits = (Map<Integer, Integer>) request.getAttribute("waitlistMap");
        %>
        <div style="display:flex; gap:15px; margin-bottom: 30px;">
            <div style="background: #fff; padding:20px; border-radius:8px; border:1px solid #e5e7eb; flex:1; text-align:center; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <h4 style="color:#6b7280; font-size:14px; margin-bottom: 5px;">Total Events Created</h4>
                <div style="font-size:28px; font-weight:bold; color:#1f2937;"><%= totalEvents != null ? totalEvents : 0 %></div>
            </div>
            <div style="background: #fff; padding:20px; border-radius:8px; border:1px solid #e5e7eb; flex:1; text-align:center; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <h4 style="color:#6b7280; font-size:14px; margin-bottom: 5px;">Total Seats Available</h4>
                <div style="font-size:28px; font-weight:bold; color:#1f2937;"><%= totalSeats != null ? totalSeats : 0 %></div>
            </div>
            <div style="background: #fff; padding:20px; border-radius:8px; border:1px solid #e5e7eb; flex:1; text-align:center; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                <h4 style="color:#6b7280; font-size:14px; margin-bottom: 5px;">People on Waitlist</h4>
                <div style="font-size:28px; font-weight:bold; color:#e15a42;"><%= totalWait != null ? totalWait : 0 %></div>
            </div>
        </div>

        <% if (list == null || list.isEmpty()) { %>
            <div class="empty">You have not created any events yet.</div>
        <% } else { %>
            <% for (Event e : list) { 
                boolean isHidden = "HIDDEN".equals(e.getStatus());
                int registeredCount = e.getCapacity() - e.getAvailableSeats();
                boolean isPaid = "PAID".equals(e.getParticipationMode());
                Double revObj = revenueMap != null ? revenueMap.get(e.getId()) : null;
                double revenue = revObj != null ? revObj : 0.0;
            %>
                <div class="event-card">
                    <div class="card-header">
                        <div>
                            <h3><%= e.getTitle() %></h3>
                            <span class="badge <%= isHidden ? "badge-hidden" : "badge-active" %>">
                                <%= isHidden ? "HIDDEN & OFFLINE" : "PUBLISHED & LIVE" %>
                            </span>
                        </div>
                    </div>

                    <div class="grid-container">
                        <div class="details-section">
                            <p><strong>Date:</strong> <%= e.getEventDate() %></p>
                            <p><strong>Location:</strong> <%= e.getLocation() %></p>
                            <p><strong>Format:</strong> <%= e.getEventType() %></p>
                            <p><strong>Status:</strong> <%= e.getParticipationMode() %> <%= isPaid ? "(₹" + String.format("%.0f", e.getPrice()) + ")" : "" %></p>
                        </div>

                        <div class="stats-section">
                            <div class="stats-row">
                                <span class="stats-title">Registrations:</span>
                                <span class="stats-value"><%= registeredCount %> / <%= e.getCapacity() %></span>
                            </div>
                            <div class="stats-row">
                                <span class="stats-title">Waitlisted:</span>
                                <span class="stats-value"><%= waits != null && waits.containsKey(e.getId()) ? waits.get(e.getId()) : "0" %> Users</span>
                            </div>
                            <% if (isPaid) { %>
                                <div class="stats-row">
                                    <span class="stats-title">Verified Rev:</span>
                                    <span class="stats-value" style="color:#10b981;">₹<%= String.format("%.0f", revenue) %></span>
                                </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="actions">
                        <form action="<%= request.getContextPath() %>/toggle-event-status" method="post" style="display:inline;">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <% if (isHidden) { %>
                                <button type="submit" class="btn-toggle btn-publish">Publish Publicly</button>
                            <% } else { %>
                                <button type="submit" class="btn-toggle btn-hide" onclick="return confirm('Hiding this event will remove it from the public page. Proceed?');">Hide Event</button>
                            <% } %>
                        </form>
                        
                        <div>
                            <a href="<%= request.getContextPath() %>/event-checkin?eventId=<%= e.getId() %>" class="btn-export" style="background-color:#3b82f6; margin-right: 5px;">Check-In</a>
                            <a href="<%= request.getContextPath() %>/jsp/edit-event.jsp?eventId=<%= e.getId() %>" class="btn-export" style="background-color:#10b981; margin-right: 5px;">Edit</a>
                            <a href="<%= request.getContextPath() %>/export-data?eventId=<%= e.getId() %>" class="btn-export">Data</a>
                            <form action="<%= request.getContextPath() %>/delete-event" method="post" style="display:inline; margin-left:5px;">
                                <input type="hidden" name="eventId" value="<%= e.getId() %>">
                                <button type="submit" class="btn-toggle btn-hide" style="background-color:#ef4444;" onclick="return confirm('WARNING: Are you absolutely sure? This drops all registrations permanently.');">Delete</button>
                            </form>
                        </div>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>
