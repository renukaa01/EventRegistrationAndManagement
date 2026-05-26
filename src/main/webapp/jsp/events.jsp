<%@ page import="java.util.*, com.event.model.*, com.event.service.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
List<Event> events = (List<Event>) request.getAttribute("events");
User user = null; boolean isOrganizer = false;
HttpSession sess = request.getSession(false);
if (sess != null) { user = (User) sess.getAttribute("user"); }

EventService service = new EventService();
if (user != null) {
    OrganizationService orgService = new OrganizationService();
    isOrganizer = (orgService.getOrgByAdmin(user.getId()) != null);
}

String error = request.getParameter("error"); String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Browse Events</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; }

        .navbar { background-color: #ffffff; padding: 15px 30px; border-bottom: 2px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
        .navbar .logo { font-size: 22px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .nav-links a { color: #4b5563; text-decoration: none; font-weight: bold; font-size: 15px; margin-left: 20px;}
        .nav-links a:hover { color: #e15a42; }

        .container { max-width: 1000px; margin: 40px auto; padding: 0 20px; }
        .header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 30px; border-bottom: 2px solid #e5e7eb; padding-bottom: 20px;}
        .header h2 { font-size: 28px; color: #1f2937; }
        .search-form { background: #fff; padding: 15px; border-radius: 8px; border: 1px solid #e5e7eb; display: flex; gap: 10px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.02); }
        .search-form input, .search-form select { flex: 1; padding: 10px; border: 1px solid #d1d5db; border-radius: 5px; }

        .msg { padding: 12px; border-radius: 5px; font-size: 14px; text-align: center; margin-bottom: 20px; }
        .error { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .success { background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; }

        .event-card { background-color: #ffffff; border: 1px solid #e5e7eb; border-radius: 8px; padding: 30px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.05); }
        .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
        .card-header h3 { font-size: 22px; color: #1f2937; }
        .price { font-weight: bold; font-size: 16px; color: #e15a42; }

        .badge { display: inline-block; padding: 5px 10px; border-radius: 3px; font-size: 12px; font-weight: bold; color: #ffffff; margin-right: 10px; margin-bottom: 15px; }
        .b-open { background-color: #10b981; }
        .b-col { background-color: #3b82f6; }
        .b-com { background-color: #8b5cf6; }
        .b-cap { background-color: #1f2937; }
        .b-full { background-color: #ef4444; }

        .details { background-color: #f3f4f6; padding: 15px; border-radius: 5px; margin-bottom: 20px; display: flex; justify-content: space-between;}
        .details p { font-size: 14px; color: #4b5563; }
        .details strong { color: #1f2937; }

        .desc { font-size: 15px; line-height: 1.5; color: #4b5563; margin-bottom: 25px; }

        .btn { display: inline-block; padding: 10px 20px; font-weight: bold; border-radius: 5px; font-size: 14px; text-decoration: none; border: none; cursor: pointer; text-align: center; }
        .btn-reg { background-color: #e15a42; color: #ffffff; }
        .btn-reg:hover { background-color: #c84630; }
        .btn-wait { background-color: #f59e0b; color: #ffffff; }
        .btn-log { background-color: #1f2937; color: #ffffff; }
        .btn-dis { background-color: #e5e7eb; color: #9ca3af; cursor: not-allowed; }
        .btn-rep { background-color: transparent; border: 1px solid #ef4444; color: #ef4444; float: right; }

        .empty { text-align: center; background: #ffffff; padding: 50px; border: 1px solid #e5e7eb; border-radius: 8px; color: #6b7280; }
    </style>
</head>
<body>

    <div class="navbar">
        <a href="<%= request.getContextPath() %>/" class="logo">Event Management</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/home">Dashboard</a>
        </div>
    </div>

    <div class="container">
        <div class="header">
            <h2>All Published Events</h2>
        </div>
        
        <form class="search-form" action="<%= request.getContextPath() %>/view-events" method="get">
            <input type="text" name="search" placeholder="Search by title..." value="<%= request.getParameter("search")!=null ? request.getParameter("search") : "" %>">
            <input type="date" name="date" value="<%= request.getParameter("date")!=null ? request.getParameter("date") : "" %>">
            <input type="text" name="location" placeholder="Location..." value="<%= request.getParameter("location")!=null ? request.getParameter("location") : "" %>">
            <select name="eligibility">
                <option value="">Any Eligibility</option>
                <option value="OPEN" <%= "OPEN".equals(request.getParameter("eligibility")) ? "selected" : "" %>>Open to All</option>
                <option value="COLLEGE_ONLY" <%= "COLLEGE_ONLY".equals(request.getParameter("eligibility")) ? "selected" : "" %>>College Only</option>
                <option value="COMPANY_ONLY" <%= "COMPANY_ONLY".equals(request.getParameter("eligibility")) ? "selected" : "" %>>Company Only</option>
            </select>
            <select name="event_type">
                <option value="">Any Format</option>
                <option value="INDIVIDUAL" <%= "INDIVIDUAL".equals(request.getParameter("event_type")) ? "selected" : "" %>>Individual</option>
                <option value="TEAM" <%= "TEAM".equals(request.getParameter("event_type")) ? "selected" : "" %>>Team</option>
            </select>
            <button type="submit" class="btn btn-reg" style="padding: 10px 15px;">Search</button>
            <a href="<%= request.getContextPath() %>/view-events" class="btn btn-log" style="padding: 10px 15px;">Clear</a>
        </form>

        <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
        <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

        <% if (events == null || events.isEmpty()) { %>
            <div class="empty">No events are currently published in the system.</div>
        <% } else { %>
            <% for (Event e : events) {
                boolean registered = false; boolean waitlisted = false;
                boolean eligible = service.isEligible(user, e);
                boolean isFull = e.getAvailableSeats() <= 0;
                boolean isPaid = "PAID".equals(e.getEventType());
                if (user != null) {
                    registered = service.isRegistered(user.getId(), e.getId());
                    waitlisted = service.isWaitlisted(user.getId(), e.getId());
                }
            %>
            <div class="event-card">
                <div class="card-header">
                    <h3><%= e.getTitle() %></h3>
                    <div class="price"><%= isPaid ? "₹" + String.format("%.0f", e.getPrice()) : "Free Entry" %></div>
                </div>

                <div>
                    <% String elig = e.getEligibility(); %>
                    <span class="badge <%= "COLLEGE_ONLY".equals(elig) ? "b-col" : "COMPANY_ONLY".equals(elig) ? "b-com" : "b-open" %>">
                        <%= "OPEN".equals(elig) ? "Publicly Open" : elig %>
                    </span>
                    <span class="badge <%= isFull ? "b-full" : "b-cap" %>">
                        <%= isFull ? "WAITLIST ONLY" : "Seats: " + e.getAvailableSeats() + " left" %>
                    </span>
                </div>

                <div class="details">
                    <p><strong>Date:</strong> <%= e.getEventDate() %></p>
                    <p><strong>Location:</strong> <%= e.getLocation() %></p>
                </div>
                
                <div class="desc"><%= e.getDescription() %></div>

                <div>
                    <% if (user == null) { %>
                        <a href="<%= request.getContextPath() %>/jsp/login.jsp" class="btn btn-log">Login to Register</a>
                    <% } else if (isOrganizer) { %>
                        <button class="btn btn-dis" disabled>Organizers cannot register</button>
                    <% } else if (registered) { %>
                        <a href="<%= request.getContextPath() %>/my-tickets" class="btn btn-reg" style="background-color:#3b82f6;">View My Ticket</a>
                    <% } else if (waitlisted) { %>
                        <button class="btn btn-dis" disabled>Currently on Waitlist</button>
                    <% } else if (!eligible) { %>
                        <button class="btn btn-dis" disabled>Not Eligible for Event</button>
                    <% } else if (isFull) { %>
                        <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <button type="submit" class="btn btn-wait">Join Waitlist</button>
                        </form>
                    <% } else if ("TEAM".equals(e.getEventType()) || "PAID".equals(e.getParticipationMode()) || (e.getCustomFormSchema() != null && e.getCustomFormSchema().length() > 2)) { %>
                        <form action="<%= request.getContextPath() %>/jsp/register-flow.jsp" method="get" style="display:inline;">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <button type="submit" class="btn btn-reg">Complete Registration</button>
                        </form>
                    <% } else { %>
                        <form action="<%= request.getContextPath() %>/register-event" method="post" style="display:inline;">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <button type="submit" class="btn btn-reg">Register Now</button>
                        </form>
                    <% } %>

                    <% if (user != null && !isOrganizer && !registered && !waitlisted) { %>
                        <form action="<%= request.getContextPath() %>/report-event" method="post" style="display:inline;">
                            <input type="hidden" name="eventId" value="<%= e.getId() %>">
                            <button type="submit" class="btn btn-rep">Report Issue</button>
                        </form>
                    <% } %>
                </div>
            </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>