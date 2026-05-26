<%@ page import="com.event.model.Event" %>
<%@ page import="com.event.dao.EventDAO" %>
<%@ page import="com.event.model.User" %>
<%@ page import="com.event.service.OrganizationService" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    OrganizationService orgService = new OrganizationService();
    Integer orgId = orgService.getOrgByAdmin(user.getId());
    if (orgId == null) { response.sendRedirect(request.getContextPath() + "/home"); return; }

    String eventIdStr = request.getParameter("eventId");
    if (eventIdStr == null) { response.sendRedirect(request.getContextPath() + "/manage-events"); return; }
    int eventId = Integer.parseInt(eventIdStr);

    EventDAO dao = new EventDAO();
    Event e = dao.getEventById(eventId);
    if (e == null || e.getOrganizationId() != orgId) { response.sendRedirect(request.getContextPath() + "/manage-events"); return; }
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Edit Event Configuration</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f8f9fa; color: #1f2937; padding: 40px 20px; }
        .form-container { max-width: 600px; margin: 0 auto; background: #fff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .form-container h2 { margin-bottom: 20px; font-size:24px; border-bottom:1px solid #e5e7eb; padding-bottom:15px; }
        .form-group { margin-bottom: 15px; }
        label { display: block; font-weight: bold; margin-bottom: 5px; font-size:14px; }
        input[type="text"], input[type="number"], textarea { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 5px; }
        .btn-sub { display: inline-block; padding: 10px 15px; background: #10b981; color: #fff; font-weight: bold; text-decoration: none; border-radius: 5px; border:none; cursor:pointer;}
        .msg { padding: 10px; margin-bottom: 15px; border-radius: 5px; background: #fee2e2; color: #b91c1c; font-size: 14px; text-align: center; }
    </style>
    <script>
        function togglePrice() {
            var mode = document.getElementById("pMode").value;
            var group = document.getElementById("priceGroup");
            if(mode === "PAID") {
                group.style.display = "block";
            } else {
                group.style.display = "none";
            }
        }
    </script>
</head>
<body>
<div class="form-container">
    <h2>Update Event Details</h2>
    <% if(error!=null){ %><div class="msg"><%= error %></div><% } %>
    
    <form action="<%= request.getContextPath() %>/edit-event" method="post">
        <input type="hidden" name="eventId" value="<%= e.getId() %>">
        <div class="form-group">
            <label>Event Title</label>
            <input type="text" name="title" value="<%= e.getTitle() %>" required>
        </div>
        <div class="form-group">
            <label>Location (Virtual or Physical)</label>
            <input type="text" name="location" value="<%= e.getLocation() %>" required>
        </div>
        <div class="form-group">
            <label>Event Date</label>
            <input type="date" name="eventDate" value="<%= e.getEventDate() %>" required>
        </div>
        <div class="form-group">
            <label>Entry Type</label>
            <select name="participationMode" id="pMode" style="width:100%; padding:10px; border:1px solid #d1d5db; border-radius:5px;" onchange="togglePrice()">
                <option value="FREE" <%= "FREE".equals(e.getParticipationMode()) ? "selected" : "" %>>Free Entry</option>
                <option value="PAID" <%= "PAID".equals(e.getParticipationMode()) ? "selected" : "" %>>Paid Entry</option>
            </select>
        </div>
        <div class="form-group" id="priceGroup" style='display:<%= "PAID".equals(e.getParticipationMode()) ? "block" : "none" %>'>
            <label>Ticket Price (₹)</label>
            <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="price" value='<%= String.format("%.0f", e.getPrice()) %>'>
        </div>

        <div class="form-group">
            <label>Who Can Attend</label>
            <select name="eligibility" style="width:100%; padding:10px; border:1px solid #d1d5db; border-radius:5px;">
                <option value="OPEN" <%= "OPEN".equals(e.getEligibility()) ? "selected" : "" %>>Publicly Open</option>
                <option value="COLLEGE_ONLY" <%= "COLLEGE_ONLY".equals(e.getEligibility()) ? "selected" : "" %>>College/Students Only</option>
                <option value="COMPANY_ONLY" <%= "COMPANY_ONLY".equals(e.getEligibility()) ? "selected" : "" %>>Corporate/Company Only</option>
            </select>
        </div>
        <div class="form-group">
            <label>Event Format</label>
            <select name="eventType" style="width:100%; padding:10px; border:1px solid #d1d5db; border-radius:5px;">
                <option value="INDIVIDUAL" <%= "INDIVIDUAL".equals(e.getEventType()) ? "selected" : "" %>>Individual Action</option>
                <option value="TEAM" <%= "TEAM".equals(e.getEventType()) ? "selected" : "" %>>Team Oriented</option>
            </select>
        </div>
        <div class="form-group">
            <label>Total Tickets Available (Must be &ge; Current Registrations)</label>
            <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="capacity" value="<%= e.getCapacity() %>" required>
        </div>
        <div class="form-group">
            <label>Description Details</label>
            <textarea name="description" rows="5"><%= e.getDescription() %></textarea>
        </div>
        <button type="submit" class="btn-sub">Finalize Updates</button>
        <a href="<%= request.getContextPath() %>/manage-events" style="margin-left:15px; color:#6b7280; font-size:14px;">Cancel</a>
    </form>
</div>
</body>
</html>
