/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.event.controller;

import java.io.IOException;
import java.io.PrintWriter;
import com.event.dao.EventDAO;
import com.event.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author User
 */
@WebServlet("/CalendarDataServlet")
public class CalendarDataServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        EventDAO dao = new EventDAO();
        List<Event> events = dao.getAllEvents();
        
        // We manually build a simple JSON string
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < events.size(); i++) {
            Event e = events.get(i);
            json.append("{")
                .append("\"id\":\"").append(e.getEventID()).append("\",")
                .append("\"title\":\"").append(e.getEventTitle()).append("\",")
                .append("\"start\":\"").append(e.getEventDate()).append("T").append(e.getStartTime()).append("\",")
                .append("\"extendedProps\": {")
                .append("\"venue\":\"").append(e.getEventVenue()).append("\",")
                .append("\"time\":\"").append(e.getStartTime()).append("\"")
                .append("}")
                .append("}");
            if (i < events.size() - 1) json.append(",");
        }
        json.append("]");

        response.setContentType("application/json");
        response.getWriter().write(json.toString());
    }
}