/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.event.controller;

import com.event.dao.RegistrationDAO;
import com.event.dao.EventDAO;
import com.event.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author User
 */

@WebServlet("/EventRegistrationServlet")
public class EventRegistrationServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int eventId = Integer.parseInt(request.getParameter("eventId"));
        String action = request.getParameter("action"); 
        RegistrationDAO regDao = new RegistrationDAO();

        // Check if the student clicked "Cancel"
        if ("cancel".equals(action)) {
            if (regDao.cancelByUserAndEvent(user.getUserID(), eventId)) {
                response.sendRedirect("event-details.jsp?id=" + eventId + "&msg=cancelled");
            } else {
                response.sendRedirect("event-details.jsp?id=" + eventId + "&msg=error");
            }
            return; // Stop execution here
        }

        // Otherwise, proceed with REGISTRATION logic
        EventDAO eventDao = new EventDAO();
        int max = eventDao.getEventById(eventId).getMaxCapacity();
        int current = regDao.getConfirmedCount(eventId);
        String status = (current < max) ? "Confirmed" : "Waiting";
        
        if (regDao.register(user.getUserID(), eventId, status)) {
            response.sendRedirect("event-details.jsp?id=" + eventId + "&msg=success&type=" + status);
        } else {
            response.sendRedirect("event-details.jsp?id=" + eventId + "&msg=error");
        }
    }
}