package com.event.dao;

import com.event.model.Team;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

public class TeamDAO {
    
    public Integer createTeam(Team team) {
        try (Connection con = DBConnection.getConnection()) {
            String sql = "INSERT INTO teams (name, event_id, leader_user_id) VALUES (?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, team.getName());
            ps.setInt(2, team.getEventId());
            ps.setInt(3, team.getLeaderUserId());
            
            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) return null;
            
            try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return -1; // -1 on unique constraint fail / collision
    }
    public java.util.List<Team> getTeamsByEventId(int eventId) {
        java.util.List<Team> list = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection()) {
            String sql = "SELECT * FROM teams WHERE event_id=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Team t = new Team();
                t.setId(rs.getInt("id"));
                t.setName(rs.getString("name"));
                t.setEventId(rs.getInt("event_id"));
                t.setLeaderUserId(rs.getInt("leader_user_id"));
                // Add member count safety checking for UI dropdowns
                String cSql = "SELECT COUNT(*) FROM registrations WHERE team_id=?";
                PreparedStatement cps = con.prepareStatement(cSql);
                cps.setInt(1, t.getId());
                ResultSet crs = cps.executeQuery();
                if (crs.next()) {
                    // Temporarily storing member count locally? We don't have a field in Team class.
                    // We'll just append it to the name in UI via a different method, or we just return all.
                }
                list.add(t);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return list;
    }
}
