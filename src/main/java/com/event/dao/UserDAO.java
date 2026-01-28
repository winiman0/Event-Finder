package com.event.dao;

import com.event.model.User;
import com.event.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

                // FIX: You were missing these! 
                // Without these, the session object is empty on login
                user.setPhoneNumber(rs.getString("Phone")); 
                user.setFaculty(rs.getString("Faculty"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return user;
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
        String sql = "SELECT u.*, c.CampusName, c.CampusState FROM USERS u " +
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
                u.setFaculty(rs.getString("Faculty")); // Added this too
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
    
    
    public User getUserByID(String userID) {
        User user = null;
        // Join with Campus to get full details in one go
        String sql = "SELECT u.*, c.CampusName, c.CampusState " +
                     "FROM USERS u " +
                     "LEFT JOIN CAMPUS c ON u.CampusID = c.CampusID " +
                     "WHERE u.UserID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = new User();
                user.setUserID(rs.getString("UserID"));
                user.setFullName(rs.getString("FullName"));
                user.setEmail(rs.getString("Email"));
                user.setRole(rs.getString("Role"));
                user.setCampusID(rs.getString("CampusID"));
                user.setPhoneNumber(rs.getString("Phone"));
                user.setFaculty(rs.getString("Faculty"));
                user.setCampusName(rs.getString("CampusName"));
                user.setCampusState(rs.getString("CampusState"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return user;
    }
    public int getUserTotalMerit(String userID) {
        int total = 0;

        // Calculate Semester Dates
        java.time.LocalDate now = java.time.LocalDate.now();
        int month = now.getMonthValue();
        int year = now.getYear();
        java.sql.Date startDate, endDate;

        if (month >= 3 && month <= 8) { // March to August
            startDate = java.sql.Date.valueOf(year + "-03-01");
            endDate = java.sql.Date.valueOf(year + "-08-31");
        } else { // September to February (Sem 1 crossover)
            if (month >= 9) {
                startDate = java.sql.Date.valueOf(year + "-09-01");
                endDate = java.sql.Date.valueOf((year + 1) + "-02-28");
            } else {
                startDate = java.sql.Date.valueOf((year - 1) + "-09-01");
                endDate = java.sql.Date.valueOf(year + "-02-28");
            }
        }

        String sql = "SELECT SUM(e.MeritPoints) FROM REGISTRATION r " +
                     "JOIN EVENT e ON r.EventID = e.EventID " +
                     "WHERE r.UserID = ? AND LOWER(r.Status) = 'attended' " +
                     "AND e.EventDate BETWEEN ? AND ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt(1); 
            }
        } catch (Exception e) { e.printStackTrace(); }
        return total;
    }

    public List<String[]> getMeritHistory(String userID) {
        List<String[]> history = new ArrayList<>();

        // Use the same date logic as above to keep them synced
        java.time.LocalDate now = java.time.LocalDate.now();
        int month = now.getMonthValue();
        int year = now.getYear();
        java.sql.Date startDate, endDate;

        if (month >= 3 && month <= 8) {
            startDate = java.sql.Date.valueOf(year + "-03-01");
            endDate = java.sql.Date.valueOf(year + "-08-31");
        } else {
            if (month >= 9) {
                startDate = java.sql.Date.valueOf(year + "-09-01");
                endDate = java.sql.Date.valueOf((year + 1) + "-02-28");
            } else {
                startDate = java.sql.Date.valueOf((year - 1) + "-09-01");
                endDate = java.sql.Date.valueOf(year + "-02-28");
            }
        }

        String sql = "SELECT e.EventTitle, e.MeritPoints FROM REGISTRATION r " +
                     "JOIN EVENT e ON r.EventID = e.EventID " +
                     "WHERE r.USERID = ? AND LOWER(r.STATUS) = 'attended' " +
                     "AND e.EventDate BETWEEN ? AND ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                history.add(new String[]{rs.getString("EventTitle"), rs.getString("MeritPoints")});
            }
        } catch (Exception e) { e.printStackTrace(); }
        return history;
    }
    public boolean deleteUser(String userId) {
        
        String sql1 = "DELETE FROM REGISTRATION WHERE UserID = ?";
        String sql2 = "DELETE FROM USERS WHERE UserID = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); 

            try (PreparedStatement ps1 = conn.prepareStatement(sql1);
                 PreparedStatement ps2 = conn.prepareStatement(sql2)) {

                ps1.setString(1, userId);
                ps1.executeUpdate(); 

                ps2.setString(1, userId);
                int rows = ps2.executeUpdate(); 

                conn.commit();
                return rows > 0;
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateUserByAdmin(User user) {
        // Note the order: 1:Name, 2:Email, 3:Phone, 4:Faculty, 5:Role, 6:CampusID, 7:UserID
        String sql = "UPDATE USERS SET FullName = ?, Email = ?, Phone = ?, Faculty = ?, Role = ?, CampusID = ? WHERE UserID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhoneNumber());
            ps.setString(4, user.getFaculty());
            ps.setString(5, user.getRole());
            ps.setString(6, user.getCampusID()); // This MUST be the ID, not the Name
            ps.setString(7, user.getUserID());

            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (Exception e) {
            e.printStackTrace(); // THIS WILL TELL YOU WHY IT FAILED in the console
            return false;
        }
    }
    public List<String[]> getAllCampusesForDropdown() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT CampusID, CampusName FROM CAMPUS";
        try (Connection conn = com.event.util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                // Stores ID at index 0 and Name at index 1
                list.add(new String[]{rs.getString("CampusID"), rs.getString("CampusName")});
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public Map<String, Integer> getPastSemestersSummary(String userID) {
        Map<String, Integer> archive = new LinkedHashMap<>();

        // 1. Identify what the "Current" semester label is based on today's date
        String currentSemLabel = getSemesterLabel(java.sql.Date.valueOf(java.time.LocalDate.now()));

        String sql = "SELECT e.EventDate, e.MeritPoints FROM REGISTRATION r " +
                     "JOIN EVENT e ON r.EventID = e.EventID " +
                     "WHERE r.UserID = ? AND LOWER(r.Status) = 'attended' " +
                     "ORDER BY e.EventDate DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                java.sql.Date d = rs.getDate("EventDate");
                int points = rs.getInt("MeritPoints");
                String semLabel = getSemesterLabel(d);

                // 2. ONLY add to archive if it's NOT the current semester
                if (!semLabel.equals(currentSemLabel)) {
                    archive.put(semLabel, archive.getOrDefault(semLabel, 0) + points);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return archive;
    }
    // Helper method to keep your code clean
    private String getSemesterLabel(java.sql.Date date) {
        java.time.LocalDate ld = date.toLocalDate();
        int month = ld.getMonthValue();
        int year = ld.getYear();

        if (month >= 3 && month <= 8) {
            return "Semester 2 (" + year + ")";
        } else {
            int year1 = (month >= 9) ? year : year - 1;
            int year2 = (month >= 9) ? year + 1 : year;
            return "Semester 1 (" + year1 + "/" + year2 + ")";
        }
    }
}