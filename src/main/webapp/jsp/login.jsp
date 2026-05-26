<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
String success = request.getParameter("success");
String redirect = request.getParameter("redirect");

if (session.getAttribute("user") != null) {
    response.sendRedirect(request.getContextPath() + "/home");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login - Event Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f8f9fa; color: #1f2937;
            display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh;
        }

        .navbar {
            position: absolute; top: 0; width: 100%;
            background-color: #ffffff; padding: 15px 30px;
            border-bottom: 2px solid #e5e7eb; display: flex; justify-content: space-between;
        }
        .navbar .logo { font-size: 22px; font-weight: bold; color: #1f2937; text-decoration: none; }
        .navbar a { text-decoration: none; color: #4b5563; font-weight: bold; font-size: 15px; }

        .auth-container {
            width: 100%; max-width: 450px; background-color: #ffffff; 
            padding: 40px; border: 1px solid #e5e7eb; border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05); margin-top: 60px;
        }

        .auth-container h2 { text-align: center; margin-bottom: 30px; font-size: 24px; color: #1f2937; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #4b5563; }
        .form-group input { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 5px; font-size: 15px; }
        .form-group input:focus { outline: none; border-color: #1f2937; }

        .btn {
            width: 100%; padding: 14px; background-color: #1f2937; color: #ffffff; 
            border: none; border-radius: 5px; font-size: 16px; font-weight: bold; 
            cursor: pointer; transition: background 0.2s; margin-top: 10px;
        }
        .btn:hover { background-color: #e15a42; }

        .msg { padding: 12px; border-radius: 5px; font-size: 14px; text-align: center; margin-bottom: 20px; }
        .error { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .success { background-color: #dcfce7; color: #15803d; border: 1px solid #86efac; }
        
        .footer-links { text-align: center; margin-top: 20px; font-size: 14px; }
        .footer-links a { color: #e15a42; text-decoration: none; font-weight: bold; }
        .footer-links a:hover { text-decoration: underline; }
    </style>
</head>
<body>

    <div class="navbar">
        <a href="<%= request.getContextPath() %>/" class="logo">Event Management</a>
        <a href="<%= request.getContextPath() %>/">← Back to Home</a>
    </div>

    <div class="auth-container">
        <h2>User Login</h2>

        <% if (error != null) { %> <div class="msg error"><%= error %></div> <% } %>
        <% if (success != null) { %> <div class="msg success"><%= success %></div> <% } %>

        <form action="<%= request.getContextPath() %>/login" method="post">
            <% if (redirect != null && !redirect.isEmpty()) { %>
                <input type="hidden" name="redirect" value="<%= redirect %>">
            <% } %>

            <div class="form-group">
                <label>Email Address</label>
                <input type="email" name="email" required autocomplete="email">
            </div>

            <div class="form-group">
                <label>Password</label>
                <input type="password" name="password" required>
            </div>

            <button type="submit" class="btn">Login</button>
        </form>

        <div class="footer-links">
            <p>Don't have an account? <a href="register.jsp">Register here</a></p>
        </div>
    </div>

</body>
</html>