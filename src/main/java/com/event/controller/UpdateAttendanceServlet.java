package com.event.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import com.event.util.DBConnection;

@WebServlet("/UpdateAttendanceServlet")
public class UpdateAttendanceServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String userId = request.getParameter("userId");
        String eventId = request.getParameter("eventId");
        String status = request.getParameter("status"); 

        try (Connection conn = DBConnection.getConnection()) {
            
            String sql = "UPDATE REGISTRATION SET Status = ? WHERE UserID = ? AND EventID = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setString(2, userId);
            ps.setInt(3, Integer.parseInt(eventId));
            ps.executeUpdate();
            
            response.getWriter().write("Success");
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(500);
        }
    }
}