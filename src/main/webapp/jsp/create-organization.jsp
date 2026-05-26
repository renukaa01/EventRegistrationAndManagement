<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
String error = request.getParameter("error");
if (session.getAttribute("user") == null) {
    response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
    return;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Create Organization</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, Helvetica, sans-serif; background-color: #f8f9fa; color: #1f2937; display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; padding: 40px 20px; }

        .form-container { width: 100%; max-width: 500px; background-color: #ffffff; padding: 40px; border: 1px solid #e5e7eb; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }

        .form-container h2 { text-align: center; margin-bottom: 30px; font-size: 24px; color: #1f2937; border-bottom: 2px solid #e5e7eb; padding-bottom: 15px;}

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; font-weight: bold; margin-bottom: 8px; font-size: 14px; color: #4b5563; }
        .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 5px; font-size: 15px; }

        .btn-group { display: flex; gap: 10px; margin-top: 30px; }
        .btn { flex: 1; padding: 14px; border: none; border-radius: 5px; font-size: 16px; font-weight: bold; cursor: pointer; text-align: center; text-decoration: none; transition: background 0.2s;}
        .btn-primary { background-color: #e15a42; color: #ffffff; }
        .btn-primary:hover { background-color: #c84630; }
        .btn-secondary { background-color: #f3f4f6; color: #1f2937; border: 1px solid #d1d5db;}
        .btn-secondary:hover { background-color: #e5e7eb; }

        .msg { padding: 12px; border-radius: 5px; font-size: 14px; text-align: center; margin-bottom: 20px; }
        .error { background-color: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
    </style>
</head>
<body>

<div class="form-container">
    <h2>Create Organization</h2>

    <% if (error != null) { %> <div class="msg error"><%= error %></div> <% } %>

    <form action="<%= request.getContextPath() %>/register-org" method="post">
        
        <div class="form-group">
            <label>Organization Name</label>
            <input type="text" name="name" required placeholder="Ex: IIT Bombay Cultural Committee">
        </div>

        <div class="form-group">
            <label>Organization Type</label>
            <select name="type" required>
                <option value="">-- Select Type --</option>
                <option value="COLLEGE">College or University</option>
                <option value="COMPANY">Company or Business</option>
                <option value="COMMUNITY">Community Group</option>
            </select>
        </div>

        <div class="btn-group">
            <a href="<%= request.getContextPath() %>/home" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">Create Organization</button>
        </div>
    </form>
</div>

</body>
</html>