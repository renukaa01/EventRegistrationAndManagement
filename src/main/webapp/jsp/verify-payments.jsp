<%@ page import="java.util.List, java.util.Map, com.event.model.User" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) { response.sendRedirect(request.getContextPath() + "/jsp/login.jsp"); return; }
    List<Map<String, String>> pendingList = (List<Map<String, String>>) request.getAttribute("pendingList");
    String success = (String) session.getAttribute("adminSuccess");
    if (success != null) session.removeAttribute("adminSuccess");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Verify Event Payments</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f8f9fa; color: #1f2937; padding: 40px; }
        .container { max-width: 1000px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 25px; }
        .btn-back { display: inline-block; padding: 10px 20px; background: #e5e7eb; color: #374151; text-decoration: none; border-radius: 5px; font-weight: bold; }
        .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .card { background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); }
        .card h3 { margin-bottom: 10px; font-size: 18px; color: #111827; }
        .card p { font-size: 14px; color: #4b5563; margin-bottom: 5px; }
        .card-img { width: 100%; height: 180px; object-fit: cover; border-radius: 4px; margin: 10px 0; border: 1px solid #e5e7eb; cursor: pointer; transition: transform 0.2s;}
        .card-img:hover { transform: scale(1.02); }
        .actions { display: flex; gap: 10px; margin-top: 15px; }
        .btn-approve { width: 100%; padding: 10px; background: #10b981; color: #fff; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; display: block;}
        .btn-reject { width: 100%; padding: 10px; background: #ef4444; color: #fff; border: none; border-radius: 5px; cursor: pointer; font-weight: bold; display: block;}
        .msg-success { padding: 15px; background: #d1fae5; color: #065f46; border-radius: 5px; margin-bottom: 20px; text-align: center; }
        .empty { text-align: center; color: #6b7280; margin-top: 50px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Payment Verification Queue</h2>
            <a href="<%= request.getContextPath() %>/manage-events" class="btn-back">← Back to Dashboard</a>
        </div>

        <% if (success != null) { %><div class="msg-success"><%= success %></div><% } %>

        <% if (pendingList == null || pendingList.isEmpty()) { %>
            <div class="empty"><h3>No Pending Payments to verify!</h3><p>Your queue is completely clear.</p></div>
        <% } else { %>
            <div class="grid">
                <% for (Map<String, String> map : pendingList) { %>
                    <div class="card">
                        <h3><%= map.get("eventTitle") %></h3>
                        <p><strong>User:</strong> <%= map.get("userName") %></p>
                        <p style="font-size:12px; color:#888;"><%= map.get("userEmail") %></p>
                        <p style="margin-top:10px; font-size:15px;"><strong>Claimed:</strong> <span style="color:#10b981;">₹<%= map.get("amount") %></span></p>
                        
                        <% 
                            String rawPath = map.get("screenshot");
                            String safePath = (rawPath != null && !rawPath.trim().isEmpty()) ? rawPath.replace("\\", "/") : ""; 
                        %>
                        <a href="<%= request.getContextPath() %>/<%= safePath %>" target="_blank">
                            <img src="<%= request.getContextPath() %>/<%= safePath %>" class="card-img" alt="Payment Screenshot" title="Click to open full size">
                        </a>

                        <div class="actions">
                            <form action="<%= request.getContextPath() %>/verify-payments" method="post" style="flex:1;">
                                <input type="hidden" name="paymentId" value="<%= map.get("paymentId") %>">
                                <input type="hidden" name="action" value="APPROVE">
                                <button type="submit" class="btn-approve">Approve</button>
                            </form>
                            <form action="<%= request.getContextPath() %>/verify-payments" method="post" style="flex:1;">
                                <input type="hidden" name="paymentId" value="<%= map.get("paymentId") %>">
                                <input type="hidden" name="action" value="REJECT">
                                <button type="submit" class="btn-reject" onclick="return confirm('Are you sure? This will permanently cancel their registration and automatically give their seat to the next person on the waitlist.');">Reject</button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
