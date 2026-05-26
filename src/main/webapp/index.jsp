<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Event Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f8f9fa;
            color: #1f2937;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .navbar {
            background-color: #ffffff;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #e5e7eb;
        }
        .navbar .logo { font-size: 22px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .nav-links a { margin-left: 20px; text-decoration: none; color: #4b5563; font-weight: bold; font-size: 15px; }
        .nav-links a:hover { color: #e15a42; }

        .header-section {
            background-color: #1f2937;
            color: #ffffff;
            padding: 60px 20px;
            text-align: center;
        }
        .header-section h1 { font-size: 40px; margin-bottom: 20px; }
        .header-section p { font-size: 18px; color: #d1d5db; max-width: 700px; margin: 0 auto 30px auto; line-height: 1.5;}
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            font-weight: bold;
            text-decoration: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            border: none;
        }
        .btn-primary { background-color: #e15a42; color: #ffffff; }
        .btn-primary:hover { background-color: #c84630; }
        .btn-secondary { background-color: #ffffff; color: #1f2937; margin-left: 10px; }
        .btn-secondary:hover { background-color: #e5e7eb; }

        .container { max-width: 1100px; margin: 50px auto; padding: 0 20px; }
        
        .section-title { text-align: center; margin-bottom: 40px; font-size: 28px; color: #1f2937; }

        .feature-container {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        .feature-box {
            background-color: #ffffff;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 30px;
            flex: 1;
            min-width: 300px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .feature-box h3 { font-size: 20px; margin-bottom: 15px; color: #1f2937; }
        .feature-box p { font-size: 15px; color: #4b5563; line-height: 1.5; }

        .footer {
            background-color: #ffffff;
            text-align: center;
            padding: 20px;
            margin-top: auto;
            border-top: 1px solid #e5e7eb;
            color: #6b7280;
            font-size: 14px;
        }
    </style>
</head>
<body>

    <div class="navbar">
        <a href="<%= request.getContextPath() %>/" class="logo">Event Management System</a>
        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/view-events">Browse Events</a>
            <a href="<%= request.getContextPath() %>/jsp/login.jsp">Login</a>
            <a href="<%= request.getContextPath() %>/jsp/register.jsp" class="btn btn-primary" style="color: white;">Register</a>
        </div>
    </div>

    <div class="header-section">
        <h1>Welcome to the Campus Event Portal</h1>
        <p>A centralized platform to discover, register, and manage campus events, corporate seminars, and public activities seamlessly.</p>
        <div>
            <a href="<%= request.getContextPath() %>/jsp/register.jsp" class="btn btn-primary">Create an Account</a>
            <a href="<%= request.getContextPath() %>/view-events" class="btn btn-secondary">View Events</a>
        </div>
    </div>

    <div class="container">
        <h2 class="section-title">System Features</h2>
        
        <div class="feature-container">
            <div class="feature-box">
                <h3>For Students & Users</h3>
                <p>Easily browse all upcoming events. See real-time available capacity, register for open seats, or join the automated waitlist if the event is full.</p>
            </div>
            
            <div class="feature-box">
                <h3>For Organizers</h3>
                <p>If you create an Organization, you gain admin access to publish events, track total attendee counts, and monitor registration revenue directly.</p>
            </div>
            
            <div class="feature-box">
                <h3>Secure Operations</h3>
                <p>The system enforces strict role-based access. Registrations are linked cleanly to your user profile and event capacities are tracked via the database.</p>
            </div>
        </div>
    </div>

    <div class="footer">
        Event Registration and Management System
    </div>

</body>
</html>