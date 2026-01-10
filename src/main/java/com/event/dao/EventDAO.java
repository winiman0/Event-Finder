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
        String sql = "SELECT e.*, c.CampusName, o.OrganizerName " +
                     "FROM EVENT e " +
                     "LEFT JOIN CAMPUS c ON e.CampusID = c.CampusID " +
                     "LEFT JOIN ORGANIZER o ON e.OrganizerID = o.OrganizerID " +
                     "ORDER BY e.EventDate ASC";

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
        String sql = "SELECT * FROM EVENT WHERE CampusID = ? ORDER BY EventDate ASC";

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
    public int addEvent(Event event) { // Changed return type from boolean to int
            String sql = "INSERT INTO EVENT (OrganizerID, CampusID, EventTitle, Description, EventType, EventVenue, EventDate, StartTime, EndTime, ImageURL, Status, MeritPoints, MaxCapacity) VALUES (?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            // Notice the Statement.RETURN_GENERATED_KEYS flag
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setInt(1, event.getOrganizerID());
                ps.setString(2, event.getCampusID());
                ps.setString(3, event.getEventTitle());
                ps.setString(4, event.getDescription());
                ps.setString(5, event.getEventType());
                ps.setString(6, event.getEventVenue());
                ps.setDate(7, event.getEventDate());
                ps.setTime(8, event.getStartTime());
                ps.setTime(9, event.getEndTime());
                ps.setString(10, event.getImageURL());
                ps.setString(11, event.getStatus());
                ps.setInt(12, event.getMeritPoints());
                ps.setInt(13, event.getMaxCapacity());

                int affectedRows = ps.executeUpdate();
                if (affectedRows > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) return rs.getInt(1); // Return the new ID
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return -1; // failure
        }

    // 2. 
        private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
            Event e = new Event();
            e.setEventID(rs.getInt("EventID"));
            e.setOrganizerID(rs.getInt("OrganizerID"));
            e.setCampusID(rs.getString("CampusID"));

            // Read the Joined Names
            try { 
                e.setCampusName(rs.getString("CampusName")); 
                e.setOrganizerName(rs.getString("OrganizerName")); 
            } catch (SQLException ex) {
                // Fallback if the names weren't in the query
            }

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
    
    public List<String> getAllCampusesFromTable() {
        List<String> list = new ArrayList<>();
        // We query the CAMPUSES table directly, not the events table
        String sql = "SELECT campusName FROM campus ORDER BY campusName ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(rs.getString("campusName"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list; 
    }
    
    // 4. Fetch a single event for Editing
    public Event getEventById(int id) {
        // We select everything from event (e.*) plus the specific names from joined tables
        String sql = "SELECT e.*, c.CampusName, o.OrganizerName " +
                     "FROM EVENT e " +
                     "LEFT JOIN CAMPUS c ON e.CampusID = c.CampusID " +
                     "LEFT JOIN ORGANIZER o ON e.OrganizerID = o.OrganizerID " +
                     "WHERE e.EventID = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToEvent(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 5. Update an existing event
    public boolean updateEvent(Event event) {
        String sql = "UPDATE EVENT SET OrganizerID=?, CampusID=?, EventTitle=?, Description=?, EventType=?, " +
                     "EventVenue=?, EventDate=?, StartTime=?, EndTime=?, Status=?, ImageURL=?, " +
                     "MeritPoints=?, MaxCapacity=? WHERE EventID=?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, event.getOrganizerID());
            ps.setString(2, event.getCampusID());
            ps.setString(3, event.getEventTitle());
            ps.setString(4, event.getDescription());
            ps.setString(5, event.getEventType());
            ps.setString(6, event.getEventVenue());
            ps.setDate(7, event.getEventDate());
            ps.setTime(8, event.getStartTime());
            ps.setTime(9, event.getEndTime());
            ps.setString(10, event.getStatus());
            ps.setString(11, event.getImageURL());
            ps.setInt(12, event.getMeritPoints());
            ps.setInt(13, event.getMaxCapacity());
            ps.setInt(14, event.getEventID());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Fetch all organizers for the dropdown menu
    public List<String[]> getAllOrganizers() {
        List<String[]> organizers = new ArrayList<>();
        String sql = "SELECT OrganizerID, OrganizerName FROM ORGANIZER ORDER BY OrganizerName ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                organizers.add(new String[]{rs.getString("OrganizerID"), rs.getString("OrganizerName")});
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return organizers;
    }
    
    public boolean deleteEvent(int id) {
        String sql = "DELETE FROM EVENT WHERE EventID = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public Event getClosestEvent() {
        Event event = null;
        
        String sql =     
                "SELECT e.*, c.CampusName, o.OrganizerName " +
                "FROM EVENT e " +
                "LEFT JOIN CAMPUS c ON e.CampusID = c.CampusID " +
                "LEFT JOIN ORGANIZER o ON e.OrganizerID = o.OrganizerID " +
                "WHERE e.EventDate >= CURRENT_DATE " +
                "ORDER BY e.EventDate ASC " +
                "FETCH FIRST 1 ROW ONLY";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                event = mapResultSetToEvent(rs);
            }
        } catch (SQLException e) { 
            System.out.println("DAO ERROR: " + e.getMessage());
            e.printStackTrace(); 
        }
        return event;
    }
    
    public List<String[]> getAllCampusesList() {
        List<String[]> list = new ArrayList<>();
        String sql = "SELECT CampusID, CampusName FROM CAMPUS ORDER BY CampusName ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new String[]{rs.getString("CampusID"), rs.getString("CampusName")});
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
    
   
    public boolean updateEventStatus(int eventId, String status) {
        
        String sql = "UPDATE EVENT SET Status = ? WHERE EventID = ?"; 
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, eventId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public void syncEventStatuses() {
        String sql = "UPDATE EVENT SET status = 'Completed' " +
                     "WHERE status = 'Upcoming' " +
                     "AND (eventDate < CURRENT_DATE OR (eventDate = CURRENT_DATE AND endTime < CURRENT_TIME))";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int rowsUpdated = ps.executeUpdate(); 
            System.out.println("Background Sync: " + rowsUpdated + " events moved to Completed.");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}