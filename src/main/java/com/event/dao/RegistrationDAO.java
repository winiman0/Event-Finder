package com.event.dao;

import com.event.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.event.model.Event;
import com.event.model.Registration;


public class RegistrationDAO {

    // 1. Core Method: Register a student
    public boolean register(String userId, int eventId, String status) {
        String sql = "INSERT INTO REGISTRATION (UserID, EventID, Status, RegTime) VALUES (?, ?, ?, CURRENT_TIMESTAMP)";
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
        // FIX: Changed "LIMIT 1" to "FETCH FIRST 1 ROWS ONLY"
        String findNext = "SELECT RegID FROM REGISTRATION WHERE EventID = ? AND Status = 'Waiting' ORDER BY RegTime ASC FETCH FIRST 1 ROWS ONLY";

        String updateStatus = "UPDATE REGISTRATION SET Status = 'Confirmed' WHERE RegID = ?";

        try (Connection conn = DBConnection.getConnection()) {
            int nextRegID = -1;

            // Step A: Find the person
            try (PreparedStatement ps1 = conn.prepareStatement(findNext)) {
                ps1.setInt(1, eventId);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (rs.next()) {
                        nextRegID = rs.getInt("RegID");
                    }
                }
            }

            // Step B: Update them
            if (nextRegID != -1) {
                try (PreparedStatement ps2 = conn.prepareStatement(updateStatus)) {
                    ps2.setInt(1, nextRegID);
                    int rowsAffected = ps2.executeUpdate();
                    System.out.println("DEBUG: Promoted RegID " + nextRegID + ". Rows updated: " + rowsAffected);
                }
            } else {
                System.out.println("DEBUG: No one found on waitlist for Event " + eventId);
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
    String sql = "SELECT e.*, e.Status as GlobalEventStatus, r.Status as UserRegStatus " +
                 "FROM EVENT e " +
                 "JOIN REGISTRATION r ON e.EventID = r.EventID " +
                 "WHERE r.UserID = ? AND " + 
                 (isUpcoming ? "e.EventDate >= CURRENT_DATE" : "e.EventDate < CURRENT_DATE");
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, userId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            events.add(mapResultSetToEvent(rs));
        }
        System.out.println("DEBUG: Successfully fetched " + events.size() + " events for user " + userId);
    } catch (SQLException e) { 
        System.err.println("SQL ERROR in getEventsByUser: " + e.getMessage());
    }
    return events;
}

    // Method for the Dashboard Counters
    public int getCountByUser(String userId, String type) {
        String sql = "";
        if (type.equals("total")) {
            sql = "SELECT COUNT(*) FROM REGISTRATION WHERE UserID = ?";
        } else if (type.equals("upcoming")) {
            // DERBY FIX: Use CURRENT_DATE
            sql = "SELECT COUNT(*) FROM REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID WHERE r.UserID = ? AND e.EventDate >= CURRENT_DATE";
        } else if (type.equals("week")) {
            // DERBY FIX: Derby doesn't have YEARWEEK. 
            // This is a common workaround to find events in the next 7 days:
            sql = "SELECT COUNT(*) FROM REGISTRATION r JOIN EVENT e ON r.EventID = e.EventID " +
                  "WHERE r.UserID = ? AND e.EventDate >= CURRENT_DATE AND e.EventDate <= CURRENT_DATE + 7 DAYS";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { 
            System.err.println("SQL ERROR in getCountByUser ("+type+"): " + e.getMessage());
        }
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
        e.setImageURL(rs.getString("ImageURL"));
        e.setMeritPoints(rs.getInt("MeritPoints"));
        e.setMaxCapacity(rs.getInt("MaxCapacity"));

        String userStatus = null;
        String globalStatus = null;

        try {
            globalStatus = rs.getString("GlobalEventStatus");
            userStatus = rs.getString("UserRegStatus");
        } catch (SQLException ex) {
            // Fallback if columns aren't in this specific result set
            userStatus = rs.getString("Status"); 
        }

        // LOGIC: If the Event is cancelled, the status is Cancelled.
        // Otherwise, use the user's specific status (Confirmed/Waiting).
        if ("Cancelled".equalsIgnoreCase(globalStatus)) {
            e.setStatus("Cancelled");
        } else {
            e.setStatus(userStatus);
        }

        return e;
    }
    
    public String getUserRegistrationStatus(String userId, int eventId) {
        String sql = "SELECT Status FROM REGISTRATION WHERE UserID = ? AND EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ps.setInt(2, eventId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("Status"); // Returns 'Confirmed' or 'Waiting'
        } catch (SQLException e) { e.printStackTrace(); }
        return null; // Not registered
    }
    
    public List<Event> getWaitingListByUser(String userID) {
    List<Event> events = new ArrayList<>();
 
        String sql = "SELECT e.*, r.Status as UserRegStatus FROM EVENT e " +
                     "JOIN REGISTRATION r ON e.EventID = r.EventID " +
                     "WHERE r.UserID = ? AND r.Status = 'Waiting'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                // FIX: Removed the ", true" because your method only takes 'rs'
                events.add(mapResultSetToEvent(rs)); 
            }
            System.out.println("DEBUG: Waiting list fetched: " + events.size());
        } catch (SQLException e) {
            System.err.println("DAO ERROR (getWaitingListByUser): " + e.getMessage());
        }
        return events;
    }

    public List<Event> getPastEventsByUser(String userId) {
        List<Event> events = new ArrayList<>();
        // DERBY FIX: Use CURRENT_DATE
        String sql = "SELECT e.*, r.Status as UserRegStatus FROM EVENT e " +
                     "JOIN REGISTRATION r ON e.EventID = r.EventID " +
                     "WHERE r.UserID = ? AND e.EventDate < CURRENT_DATE";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                events.add(mapResultSetToEvent(rs));
            }
        } catch (SQLException e) { 
            System.err.println("SQL ERROR in getPastEvents: " + e.getMessage());
        }
        return events;
    }
    
    public boolean updateAttendance(String userID, int eventID, String newStatus) {
        String sql = "UPDATE REGISTRATION SET Status = ? WHERE UserID = ? AND EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newStatus); 
            ps.setString(2, userID);
            ps.setInt(3, eventID);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); }
        return false;
    }
    
    public List<Registration> getRegistrationsByEvent(int eventId) {
        List<Registration> list = new ArrayList<>();
        String query = "SELECT r.*, u.fullName FROM REGISTRATION r " +
                       "JOIN USERS u ON r.UserID = u.UserID " +
                       "WHERE r.EventID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, eventId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Registration reg = new Registration();
                reg.setUserID(rs.getString("UserID"));
                reg.setEventID(rs.getInt("EventID"));
                reg.setStatus(rs.getString("Status"));
                reg.setFullName(rs.getString("fullName")); 
                list.add(reg);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
