/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.event.controller;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.event.util.DBConnection;
import java.sql.*;

/**
 *
 * @author User
 */
@WebServlet("/ExportParticipantsServlet")
public class ExportParticipantsServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String eventIdParam = request.getParameter("eventId");
        if (eventIdParam == null) return;
        
        int eventId = Integer.parseInt(eventIdParam);
        
        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=participants_event_" + eventId + ".csv");
        
        try (PrintWriter writer = response.getWriter()) {
            // Updated Headers
            writer.println("Student ID, Full Name, Email, Status, Registration Date");
            
            // Fixed column names: FullName (from your User model) and RegTime (from your DAO)
            String sql = "SELECT u.UserID, u.FullName, u.Email, r.Status, r.RegTime " +
                         "FROM REGISTRATION r JOIN USERS u ON r.UserID = u.UserID " +
                         "WHERE r.EventID = ?";
            
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, eventId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    writer.println(rs.getString("UserID") + "," + 
                                   rs.getString("FullName") + "," + 
                                   rs.getString("Email") + "," + 
                                   rs.getString("Status") + "," +
                                   rs.getTimestamp("RegTime")); // Use getTimestamp for date + time
                }
            } catch (Exception e) { e.printStackTrace(); }
        }
    }
}