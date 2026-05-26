<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
String success = request.getParameter("success");
if (session.getAttribute("user") == null) {
    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Event</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; padding: 40px 20px; }

        .form-container { max-width: 800px; margin: 0 auto; background-color: #ffffff; padding: 40px; border: 1px solid #e5e7eb; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .form-container h2 { font-size: 26px; margin-bottom: 25px; color: #1f2937; border-bottom: 2px solid #e5e7eb; padding-bottom: 15px;}

        .form-row { display: flex; gap: 20px; margin-bottom: 15px; }
        .form-group { flex: 1; }
        .form-group.full { width: 100%; margin-bottom: 15px; }
        
        label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #4b5563; }
        input[type="text"], input[type="date"], input[type="number"], select, textarea { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 5px; font-size: 15px; font-family: inherit;}
        textarea { resize: vertical; min-height: 100px; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #1f2937; }

        .btn-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 14px; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; text-align: center; text-decoration: none; transition: background 0.2s;}
        .btn-primary { background-color: #e15a42; color: #ffffff; }
        .btn-primary:hover { background-color: #c84630; }
        .btn-secondary { background-color: #f3f4f6; color: #1f2937; border: 1px solid #d1d5db;}
        .btn-secondary:hover { background-color: #e5e7eb; }

        .msg { padding: 12px; border-radius: 5px; font-size: 14px; text-align: center; margin-bottom: 20px; }
        .error { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .success { background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; }
        
        .toggle-group { display: none; background-color: #f9fafb; padding: 15px; border-radius: 5px; border: 1px dashed #d1d5db; margin-top: 10px;}
    </style>
    <script>
        function toggleFields() {
            var partMode = document.getElementById("partMode").value;
            var priceGroup = document.getElementById("priceGroup");
            var priceInput = document.getElementById("priceInput");
            if (partMode === "PAID") {
                priceGroup.style.display = "block"; priceInput.required = true;
            } else {
                priceGroup.style.display = "none"; priceInput.required = false; priceInput.value = "0";
            }

            var eventType = document.getElementById("eventType").value;
            var teamGroup = document.getElementById("teamGroup");
            var minInput = document.getElementById("minTeam");
            var maxInput = document.getElementById("maxTeam");
            if (eventType === "TEAM") {
                teamGroup.style.display = "flex"; minInput.required = true; maxInput.required = true;
            } else {
                teamGroup.style.display = "none"; minInput.required = false; maxInput.required = false;
            }
        }
    </script>
</head>
<body>

<div class="form-container">
    <h2>Create New Event</h2>

    <% if (error != null) { %><div class="msg error"><%= error %></div><% } %>
    <% if (success != null) { %><div class="msg success"><%= success %></div><% } %>

    <form action="<%= request.getContextPath() %>/add-event" method="post">
        
        <div class="form-group full">
            <label>Event Title</label>
            <input type="text" name="title" required placeholder="e.g. Technozion 2026">
        </div>

        <div class="form-group full">
            <label>Event Description</label>
            <textarea name="description" required placeholder="Required background info..."></textarea>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Event Date</label><input type="date" name="date" required>
            </div>
            <div class="form-group">
                <label>Event Location</label><input type="text" name="location" required placeholder="Main Auditorium or Mumbai">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Who Can Attend</label>
                <select name="eligibility" required>
                    <option value="OPEN">Open to Public</option>
                    <option value="COLLEGE_ONLY">College Students Only</option>
                    <option value="COMPANY_ONLY">Company Employees Only</option>
                </select>
            </div>
            <div class="form-group">
                <label>Maximum Capacity (Total Seats/Tickets)</label>
                <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="capacity" required placeholder="Total Seats">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Entry Fee</label>
                <select name="participation_mode" id="partMode" onchange="toggleFields()" required>
                    <option value="FREE">Free Event</option>
                    <option value="PAID">Paid Event</option>
                </select>
            </div>
            <div class="form-group toggle-group" id="priceGroup">
                <label>Ticket Price (₹)</label>
                <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="price" id="priceInput" placeholder="e.g. 500">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Event Format</label>
                <select name="event_type" id="eventType" onchange="toggleFields()" required>
                    <option value="INDIVIDUAL">Individual Registration</option>
                    <option value="TEAM">Team Registration</option>
                </select>
            </div>
        </div>

        <div class="form-row toggle-group" id="teamGroup">
            <div class="form-group">
                <label>Min Team Size</label>
                <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="min_team_size" id="minTeam" value="1">
            </div>
            <div class="form-group">
                <label>Max Team Size</label>
                <input type="text" inputmode="numeric" pattern="[0-9]+" oninput="this.value = this.value.replace(/[^0-9]/g, '')" name="max_team_size" id="maxTeam" value="4">
            </div>
        </div>

        <div class="form-group full" style="margin-top: 20px;">
            <label>Custom Required Fields (JSON Array format)</label>
            <textarea name="custom_form_schema" placeholder='Optional. Example: [{"name": "tshirt", "label": "T-Shirt Size", "type": "text"}]'></textarea>
        </div>

        <div class="btn-group">
            <a href="<%= request.getContextPath() %>/home" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">Submit Event</button>
        </div>
    </form>
</div>

</body>
</html>