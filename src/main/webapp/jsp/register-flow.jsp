<%@ page import="java.util.*, com.event.model.*, com.event.dao.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
String eventIdStr = request.getParameter("eventId");
User user = (User) session.getAttribute("user");
if (user == null || eventIdStr == null) {
    response.sendRedirect(request.getContextPath() + "/view-events");
    return;
}
int eventId = Integer.parseInt(eventIdStr);
EventDAO dao = new EventDAO();
Event e = null;
try {
    e = dao.getEventById(eventId);
} catch (Exception ex) {
    ex.printStackTrace();
}
if (e == null) {
    response.sendRedirect(request.getContextPath() + "/view-events?error=Event+not+found");
    return;
}

boolean isTeam = "TEAM".equals(e.getEventType());
boolean isPaid = "PAID".equals(e.getParticipationMode());
boolean hasCustomFields = e.getCustomFormSchema() != null && e.getCustomFormSchema().trim().length() > 2;

List<Team> activeTeams = new ArrayList<>();
if (isTeam) {
    TeamDAO tDao = new TeamDAO();
    activeTeams = tDao.getTeamsByEventId(eventId);
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Complete Registration - Event Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; padding: 40px 20px; }

        .form-container { max-width: 700px; margin: 0 auto; background-color: #ffffff; padding: 40px; border: 1px solid #e5e7eb; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .form-container h2 { font-size: 26px; margin-bottom: 5px; color: #1f2937; }
        .header-sub { font-size: 15px; color: #4b5563; margin-bottom: 25px; border-bottom: 2px solid #e5e7eb; padding-bottom: 15px; }

        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #4b5563; }
        input[type="text"], input[type="email"], input[type="file"], input[type="number"], select, textarea { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 5px; font-size: 15px; background: #ffffff; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #1f2937; }

        .dynamic-section { background-color: #f9fafb; padding: 20px; border: 1px dashed #d1d5db; border-radius: 5px; margin-bottom: 20px; }
        .dynamic-section h3 { font-size: 18px; margin-bottom: 15px; color: #1f2937; }

        .btn-group { display: flex; gap: 15px; margin-top: 30px; }
        .btn { flex: 1; padding: 14px; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; text-align: center; text-decoration: none; transition: background 0.2s;}
        .btn-primary { background-color: #e15a42; color: #ffffff; }
        .btn-primary:hover { background-color: #c84630; }
        .btn-secondary { background-color: #f3f4f6; color: #1f2937; border: 1px solid #d1d5db;}
        .btn-secondary:hover { background-color: #e5e7eb; }

        .msg { padding: 12px; border-radius: 5px; font-size: 14px; text-align: center; margin-bottom: 20px; }
        .error { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        
        .team-member-row { display: flex; gap: 10px; margin-bottom: 10px; }
        .team-member-row input { flex: 1; }
    </style>
    <script>
        function renderCustomFields() {
            var schemaStr = document.getElementById("hiddenSchema").value;
            if(!schemaStr || schemaStr.trim() === "null" || schemaStr.length < 5) return;
            
            var container = document.getElementById("customFieldsContainer");
            try {
                var schema = JSON.parse(schemaStr);
                var html = '<h3>Additional Information required by Organizer</h3>';
                schema.forEach(function(field) {
                    html += '<div class="form-group">';
                    html += '<label>' + field.label + '</label>';
                    if(field.type === 'text') {
                        html += '<input type="text" class="custom-input" data-key="' + field.name + '" required>';
                    } else if (field.type === 'number') {
                        html += '<input type="number" class="custom-input" data-key="' + field.name + '" required>';
                    } else if (field.type === 'select' && field.options) {
                        html += '<select class="custom-input" data-key="' + field.name + '" required>';
                        field.options.forEach(function(opt) {
                            html += '<option value="' + opt + '">' + opt + '</option>';
                        });
                        html += '</select>';
                    }
                    html += '</div>';
                });
                container.innerHTML = html;
                container.style.display = 'block';
            } catch(e) {
                console.error("Invalid Custom Schema JSON", e);
            }
        }

        function serializeForm(event) {
            // Package custom fields
            var customInputs = document.querySelectorAll('.custom-input');
            if(customInputs.length > 0) {
                var ans = {};
                customInputs.forEach(function(input) {
                    ans[input.getAttribute('data-key')] = input.value;
                });
                document.getElementById("customAnswers").value = JSON.stringify(ans);
            }
            return true;
        }

        window.onload = function() {
            renderCustomFields();
        };
    </script>
</head>
<body>

<div class="form-container">
    <h2>Complete Registration: <%= e.getTitle() %></h2>
    <div class="header-sub">Please fill in the required dynamic fields to secure your participation.</div>

    <form action="<%= request.getContextPath() %>/process-registration" method="post" enctype="multipart/form-data" onsubmit="return serializeForm(event)">
        <input type="hidden" name="eventId" value="<%= e.getId() %>">
        <input type="hidden" id="customAnswers" name="custom_answers" value="">
        <input type="hidden" id="hiddenSchema" value="<%= hasCustomFields ? e.getCustomFormSchema().replace("\"", "&quot;") : "" %>">

        <% if (isTeam) { %>
            <div class="dynamic-section">
                <h3>Team Configuration</h3>
                <p style="font-size: 13px; color: #4b5563; margin-bottom: 15px;">You can either Join an existing team or Create a new one. Max team size: <%= e.getMaxTeamSize() %>.</p>
                
                <div class="form-group" style="padding-bottom:15px; border-bottom:1px solid #e5e7eb;">
                    <label>Join Existing Team</label>
                    <select name="existing_team_id">
                        <option value="">-- Select Team to Join --</option>
                        <% for(Team t : activeTeams) { %>
                            <option value="<%= t.getId() %>"><%= t.getName() %></option>
                        <% } %>
                    </select>
                </div>

                <div style="margin-top:15px;">
                    <h4 style="font-size:15px; margin-bottom:10px;">OR Create New Team</h4>
                    <p style="font-size: 13px; color: #4b5563; margin-bottom: 10px;">You will be the Captain. Requires minimum of <%= e.getMinTeamSize() %> members.</p>
                    <div class="form-group">
                        <label>New Team Name</label>
                        <input type="text" name="team_name" placeholder="e.g. Tech Yoddhas">
                    </div>
                </div>
            </div>
        <% } %>

        <% if (hasCustomFields) { %>
            <div class="dynamic-section" id="customFieldsContainer" style="display:none;"></div>
        <% } %>

        <% if (isPaid) { %>
            <div class="dynamic-section">
                <h3>Payment Verification</h3>
                <p style="font-size: 13px; color: #4b5563; margin-bottom: 15px;">This is a paid event. Total cost is: <strong>₹<%= String.format("%.0f", e.getPrice()) %></strong>.</p>
                <p style="font-size: 13px; color: #4b5563; margin-bottom: 15px;">Please transfer funds to Organizer via UPI or Bank Transfer and upload screenshot confirmation.</p>
                <div class="form-group">
                    <label>Upload Payment Screenshot</label>
                    <input type="file" name="payment_screenshot" accept="image/*" required>
                </div>
            </div>
        <% } %>

        <div class="btn-group">
            <a href="<%= request.getContextPath() %>/view-events" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">Finalize Registration</button>
        </div>
    </form>
</div>

</body>
</html>
