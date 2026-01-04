package com.event.dao;

import com.event.model.Event;
import com.event.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    // 1. Fetch ALL Events (Admin view - sorted by date)
    public List<Event> getAllEvents() {
        List<Event> events = new ArrayList<>();
        // Removed the "Upcoming" filter so Admin can see everything
        String sql = "SELECT * FROM EVENT ORDER BY EventDate ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                events.add(mapResultSetToEvent(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    // 2. Fetch Events by Campus
    public List<Event> getEventsByCampus(String campusID) {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT e.* FROM EVENT e " +
                     "JOIN ORGANIZER o ON e.OrganizerID = o.OrganizerID " +
                     "WHERE o.CampusID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, campusID);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                events.add(mapResultSetToEvent(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return events;
    }

    // 3. Admin: Add New Event
    public boolean addEvent(Event event) {
        String sql = "INSERT INTO EVENT (OrganizerID, EventTitle, Description, EventType, EventVenue, EventDate, StartTime, EndTime, ImageURL, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, event.getOrganizerID());
            ps.setString(2, event.getEventTitle());
            ps.setString(3, event.getDescription());
            ps.setString(4, event.getEventType());
            ps.setString(5, event.getEventVenue());
            ps.setDate(6, event.getEventDate());
            ps.setTime(7, event.getStartTime());
            ps.setTime(8, event.getEndTime());
            ps.setString(9, event.getImageURL());
            ps.setString(10, "Upcoming"); // Default status

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Helper method: This is your "Source of Truth" for column names
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
        return e;
    }
    
    // Fixed getCount logic
    public int getCount(String tableName) {
        int count = 0;
        String sql = "SELECT COUNT(*) FROM " + tableName;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1); 
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return count;
    }

    public List<String[]> getRegistrationsPerEvent() {
        List<String[]> report = new ArrayList<>();
        String sql = "SELECT e.EventTitle, COUNT(r.RegID) as TotalReg " +
                     "FROM EVENT e LEFT JOIN REGISTRATION r ON e.EventID = r.EventID " +
                     "GROUP BY e.EventID, e.EventTitle";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                report.add(new String[]{rs.getString("EventTitle"), rs.getString("TotalReg")});
            }
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
        return report;
    }
}