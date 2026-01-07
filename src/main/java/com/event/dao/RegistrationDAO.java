package com.event.dao;

import com.event.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.event.model.Event;


public class RegistrationDAO {

    // 1. Core Method: Register a student
    public boolean register(String userId, int eventId, String status) {
        String sql = "INSERT INTO REGISTRATION (UserID, EventID, Status, RegTime) VALUES (?, ?, ?, NOW())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, eventId);
            ps.setString(3, status); // 'Confirmed' or 'Waiting'
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    

    // 2. The Promotion Logic: Call this whenever someone cancels!
    public void promoteFromWaitlist(int eventId) {
        // Find the next person in line (Oldest 'Waiting' status)
        String findNext = "SELECT RegID FROM REGISTRATION WHERE EventID = ? AND Status = 'Waiting' ORDER BY RegTime ASC LIMIT 1";
        String updateStatus = "UPDATE REGISTRATION SET Status = 'Confirmed' WHERE RegID = ?";

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Use transaction for safety

            int nextRegID = -1;
            try (PreparedStatement ps1 = conn.prepareStatement(findNext)) {
                ps1.setInt(1, eventId);
                ResultSet rs = ps1.executeQuery();
                if (rs.next()) {
                    nextRegID = rs.getInt("RegID");
                }
            }

            if (nextRegID != -1) {
                try (PreparedStatement ps2 = conn.prepareStatement(updateStatus)) {
                    ps2.setInt(1, nextRegID);
                    ps2.executeUpdate();
                    conn.commit(); // Save changes
                    System.out.println("Waitlist Promotion: RegID " + nextRegID + " is now Confirmed.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 3. Cancellation Method
    public boolean cancelRegistration(int regId, int eventId) {
        String sql = "DELETE FROM REGISTRATION WHERE RegID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, regId);
            int deleted = ps.executeUpdate();
            
            if (deleted > 0) {
                // IMPORTANT: Since a spot opened up, try to promote the next person!
                promoteFromWaitlist(eventId);
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    // Check how many people are confirmed
    public int getConfirmedCount(int eventId) {
        String sql = "SELECT COUNT(*) FROM REGISTRATION WHERE EventID = ? AND Status = 'Confirmed'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    // Check if this specific student is already in the list
    public boolean isStudentRegistered(String userId, int eventId) {
        String sql = "SELECT 1 FROM REGISTRATION WHERE UserID = ? AND EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, eventId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
    
    public boolean cancelByUserAndEvent(String userId, int eventId) {
        String sql = "DELETE FROM REGISTRATION WHERE UserID = ? AND EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, eventId);

            int deleted = ps.executeUpdate();
            if (deleted > 0) {
                // Re-use your existing promotion logic!
                promoteFromWaitlist(eventId);
                return true;
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }
    
    public List<Event> getEventsByUser(String userId, boolean isUpcoming) {
    List<Event> events = new ArrayList<>();
    // Note: We are selecting the Status from registration as well!
    String sql = "SELECT e.*, r.Status as UserRegStatus FROM EVENT e " +
                 "JOIN REGISTRATION r ON e.EventID = r.EventID " +
                 "WHERE r.UserID = ? AND " + 
                 (isUpcoming ? "e.EventDate >= CURDATE()" : "e.EventDate < CURDATE()");

    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Event e = mapResultSetToEvent(rs);
            e.setStatus(rs.getString("UserRegStatus")); 
            events.add(e);
        }
    } catch (SQLException e) { e.printStackTrace(); }
    return events;
}

    // Method for the Dashboard Counters
    public int getCountByUser(String userId, String type) {
        String sql = "";
        if (type.equals("total")) {
            sql = "SELECT COUNT(*) FROM REGISTRATION WHERE UserID = ?";
        } else if (type.equals("upcoming")) {
            sql = "SELECT COUNT(*) FROM REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID WHERE r.UserID = ? AND e.EventDate >= CURDATE()";
        } else if (type.equals("week")) {
            sql = "SELECT COUNT(*) FROM REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID WHERE r.UserID = ? AND YEARWEEK(e.EventDate, 1) = YEARWEEK(CURDATE(), 1)";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
    
    private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
        Event e = new Event();
        e.setEventID(rs.getInt("EventID"));
        e.setOrganizerID(rs.getInt("OrganizerID"));
        e.setEventTitle(rs.getString("EventTitle"));
        e.setDescription(rs.getString("Description"));
        e.setEventType(rs.getString("EventType"));
        e.setEventVenue(rs.getString("EventVenue"));
        e.setEventDate(rs.getDate("EventDate"));
        e.setStartTime(rs.getTime("StartTime"));
        e.setEndTime(rs.getTime("EndTime"));
        e.setStatus(rs.getString("Status"));
        e.setImageURL(rs.getString("ImageURL"));
        e.setMeritPoints(rs.getInt("MeritPoints"));
        e.setMaxCapacity(rs.getInt("MaxCapacity"));
        return e;
    }
}
