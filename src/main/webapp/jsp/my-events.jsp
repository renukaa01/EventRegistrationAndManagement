<%@ page import="java.util.*, com.event.model.Event, com.event.service.EventService, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> list = (List<Event>) request.getAttribute("events");
EventService service = new EventService();
User user = (User) session.getAttribute("user");
String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>My Registrations</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; }

        .navbar { background-color: #ffffff; padding: 15px 30px; border-bottom: 2px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 22px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .nav-links a { color: #4b5563; text-decoration: none; font-weight: bold; font-size: 15px; margin-left: 20px;}
        .nav-links a:hover { color: #e15a42; }

        .container { max-width: 900px; margin: 40px auto; padding: 0 20px; }
        .header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; border-bottom: 2px solid #e5e7eb; padding-bottom: 20px;}
        .header h2 { font-size: 28px; color: #1f2937; }

        .msg-success { background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; font-size: 14px; padding: 12px; border-radius: 5px; margin-bottom: 20px; text-align: center; }

        .event-card { background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 30px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .card-header h3 { font-size: 22px; color: #1f2937; }
        
        .badge { display: inline-block; padding: 5px 12px; border-radius: 5px; font-size: 13px; font-weight: bold; color: #ffffff; }
        .badge-reg { background-color: #10b981; }
        .badge-wait { background-color: #f59e0b; }

        .details { background-color: #f3f4f6; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; justify-content: space-between;}
        .details p { font-size: 14px; color: #4b5563; }
        .details strong { color: #1f2937; margin-right: 5px; }

        .desc { font-size: 15px; line-height: 1.5; color: #4b5563; margin-bottom: 25px; }

        .btn-cancel { padding: 10px 15px; background-color: transparent; border: 1px solid #ef4444; color: #ef4444; border-radius: 5px; font-size: 14px; font-weight: bold; cursor: pointer; transition: background 0.2s; }
        .btn-cancel:hover { background-color: #fee2e2; }

        .empty { text-align: center; background: #ffffff; padding: 50px; border: 1px solid #e5e7eb; border-radius: 8px; color: #6b7280; }
        .btn-browse { display: inline-block; padding: 12px 20px; background-color: #1f2937; color: #ffffff; text-decoration: none; border-radius: 5px; font-weight: bold; margin-top: 15px;}
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
            <h2>My Registrations</h2>
        </div>

        <% if (success != null) { %><div class="msg-success"><%= success %></div><% } %>

        <% if (list == null || list.isEmpty()) { %>
            <div class="empty">
                <p>You have not registered for any events yet.</p>
                <a href="<%= request.getContextPath() %>/view-events" class="btn-browse">Browse Available Events</a>
            </div>
        <% } else { %>
            <% for (Event e : list) { 
                 boolean waitlisted = false;
                 if (user != null) { waitlisted = service.isWaitlisted(user.getId(), e.getId()); }
            %>
                <div class="event-card">
                    <div class="card-header">
                        <h3><%= e.getTitle() %></h3>
                        <div class="badge <%= waitlisted ? "badge-wait" : "badge-reg" %>">
                            <%= waitlisted ? "ON WAITLIST" : "REGISTERED" %>
                        </div>
                    </div>
                    
                    <div class="details">
                        <p><strong>Date:</strong> <%= e.getEventDate() %></p>
                        <p><strong>Location:</strong> <%= e.getLocation() %></p>
                    </div>
                    
                    <div class="desc"><%= e.getDescription() %></div>
                    
                    <div style="border-top: 1px solid #e5e7eb; padding-top: 20px;">
                        <form action="<%= request.getContextPath() %>/cancel-registration" method="post" style="display:inline;" onsubmit="return confirm('Are you sure you want to cancel your registration?');">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <button type="submit" class="btn-cancel">Cancel Registration</button>
                        </form>
                    </div>
                </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>