package com.event.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.event.util.DBConnection;

@WebServlet("/export-data")
public class ExportRegistrationsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        String eventIdStr = request.getParameter("eventId");
        if (eventIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing eventId");
            return;
        }

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"event_" + eventIdStr + "_registrations.csv\"");

        try (PrintWriter out = response.getWriter();
             Connection con = DBConnection.getConnection()) {

            // Header
            out.println("Registration ID,User Name,User Email,Team Name,Custom Data,Payment Screenshot Path");

            String sql = "SELECT r.id, u.name as user_name, u.email as user_email, t.name as team_name, r.custom_answers, r.payment_screenshot_path " +
                         "FROM registrations r " +
                         "JOIN users u ON r.user_id = u.id " +
                         "LEFT JOIN teams t ON r.team_id = t.id " +
                         "WHERE r.event_id = ?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(eventIdStr));
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                out.printf("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n",
                        rs.getInt("id"),
                        rs.getString("user_name"),
                        rs.getString("user_email"),
                        rs.getString("team_name") != null ? rs.getString("team_name") : "N/A",
                        rs.getString("custom_answers") != null ? rs.getString("custom_answers").replace("\"", "'") : "None",
                        rs.getString("payment_screenshot_path") != null ? rs.getString("payment_screenshot_path") : "N/A"
                );
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
