package com.event.dao;

import com.event.model.User;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

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
    
    public List<User> getAllUsers() {
        List<User> list = new ArrayList<>();
        // Use a JOIN to get Name and State from the CAMPUS table
        String sql = "SELECT u.*, c.CampusName, c.CampusState " +
                     "FROM USERS u " +
                     "LEFT JOIN CAMPUS c ON u.CampusID = c.CampusID";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User u = new User();
                u.setUserID(rs.getString("UserID"));
                u.setFullName(rs.getString("FullName"));
                u.setEmail(rs.getString("Email"));
                u.setRole(rs.getString("Role"));
                u.setCampusID(rs.getString("CampusID"));
                u.setPhoneNumber(rs.getString("Phone")); 
               
                u.setCampusName(rs.getString("CampusName"));
                u.setCampusState(rs.getString("CampusState"));
                list.add(u);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public boolean updateProfile(User user) {
        boolean success = false;
        // We update everything EXCEPT UserID and CampusID/Role for security
        String sql = "UPDATE USERS SET FullName = ?, Email = ?, Phone = ?, Faculty = ? WHERE UserID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhoneNumber());
            ps.setString(4, user.getFaculty());
            ps.setString(5, user.getUserID());

            int rows = ps.executeUpdate();
            if (rows > 0) success = true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return success;
    }
    
    public int getUserTotalMerit(String userID) {
        int total = 0;
        // Only count points where an admin has confirmed attendance
        String sql = "SELECT SUM(e.EventPoints) FROM REGISTRATION r " +
                     "JOIN EVENT e ON r.EventID = e.EventID " +
                     "WHERE r.UserID = ? AND r.Status = 'Attended'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return total;
    }
    
    public List<String[]> getMeritHistory(String userID) {
        List<String[]> history = new ArrayList<>();
        String sql = "SELECT e.EventName, e.EventPoints FROM REGISTRATION r " +
                     "JOIN EVENT e ON r.EventID = e.EventID " +
                     "WHERE r.UserID = ? AND r.Status = 'Attended'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // Store as a pair: {Event Name, Points}
                history.add(new String[]{rs.getString("EventName"), rs.getString("EventPoints")});
            }
        } catch (Exception e) { e.printStackTrace(); }
        return history;
    }
}