package com.event.dao;

import com.event.model.User;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UserDAO {

    public User authenticateUser(String email, String password) {
        User user = null;
        String sql = "SELECT * FROM USERS WHERE Email = ? AND Password = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserID(rs.getString("UserID"));
                user.setFullName(rs.getString("FullName"));
                user.setEmail(rs.getString("Email"));
                user.setRole(rs.getString("Role"));
                user.setCampusID(rs.getString("CampusID"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user; // Returns a User object if found, or null if login fails
    }
    
        public boolean registerUser(User user) {
        boolean success = false;
        // Note: Use the column names exactly as we defined in the Derby script
        String sql = "INSERT INTO USERS (UserID, FullName, Email, Password, Role, CampusID) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getUserID());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, "student"); // Default role for new sign-ups
            ps.setString(6, user.getCampusID());

            int rows = ps.executeUpdate();
            if (rows > 0) success = true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }
        
       // Count only students
    public int getStudentCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM USERS WHERE LOWER(ROLE) = 'student'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }

    // Count all users (Admins + Students)
    public int getTotalUserCount() {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM USERS";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) { e.printStackTrace(); }
        return count;
    }
}