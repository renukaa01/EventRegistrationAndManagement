<%@ page import="com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
User user = (User) session.getAttribute("user");
if (user == null) {
    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Organizer Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f8f9fa; color: #1f2937;
            display: flex; flex-direction: column; min-height: 100vh;
        }

        .navbar {
            background-color: #ffffff; padding: 15px 30px;
            border-bottom: 2px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center;
        }
        .navbar .logo { font-size: 20px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .nav-links a { text-decoration: none; color: #4b5563; font-weight: bold; font-size: 15px; margin-left: 20px;}
        .nav-links a:hover { color: #e15a42; }

        .container { max-width: 1000px; margin: 50px auto; padding: 0 20px; flex-grow: 1; }
        
        .welcome-box {
            background-color: #1f2937; color: #ffffff;
            padding: 40px; border-radius: 8px; margin-bottom: 30px;
        }
        .welcome-box h2 { font-size: 28px; margin-bottom: 10px; }
        .welcome-box p { font-size: 16px; color: #d1d5db; }

        .dashboard-grid {
            display: flex; gap: 20px; flex-wrap: wrap;
        }

        .card {
            background-color: #ffffff; border: 1px solid #e5e7eb;
            border-radius: 8px; padding: 30px; flex: 1; min-width: 300px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .card h3 { font-size: 20px; margin-bottom: 15px; color: #1f2937; }
        .card p { font-size: 15px; color: #4b5563; margin-bottom: 25px; line-height: 1.5; }

        .btn {
            display: inline-block; padding: 12px 20px; 
            border-radius: 5px; font-size: 14px; font-weight: bold; 
            text-decoration: none; cursor: pointer; text-align: center; border: none;
        }
        .btn-primary { background-color: #e15a42; color: #ffffff; }
        .btn-primary:hover { background-color: #c84630; }
        .btn-secondary { background-color: #f3f4f6; color: #1f2937; border: 1px solid #d1d5db; }
        .btn-secondary:hover { background-color: #e5e7eb; }
    </style>
</head>
<body>

    <div class="navbar">
        <a href="<%= request.getContextPath() %>/home" class="logo">Event Management System</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/view-events">Browse Events</a>
            <a href="<%= request.getContextPath() %>/logout" style="color: #b91c1c;">Logout</a>
        </div>
    </div>

    <div class="container">
        <div class="welcome-box">
            <h2>Organizer Dashboard</h2>
            <p>Welcome back, <%= user.getName() %>. Manage your events and registrations from here.</p>
        </div>

        <div class="dashboard-grid">
            <div class="card">
                <h3>Create Event</h3>
                <p>Add a new event to the system. Set the date, location, ticket price, and maximum capacity for registrations.</p>
                <a href="<%= request.getContextPath() %>/jsp/add-event.jsp" class="btn btn-primary">Create New Event</a>
            </div>

            <div class="card">
                <h3>Manage Events</h3>
                <p>View all your published events. Track total registrations, waitlist status, and view generated revenue.</p>
                <a href="<%= request.getContextPath() %>/manage-events" class="btn btn-secondary">Manage My Events</a>
            </div>
        </div>
    </div>

</body>
</html>