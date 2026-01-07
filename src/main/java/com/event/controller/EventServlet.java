package com.event.controller;

import com.event.dao.EventDAO;
import com.event.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.Date;
import java.sql.Time;

@WebServlet("/EventServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class EventServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        EventDAO dao = new EventDAO();
        String action = request.getParameter("action");
        String idStr = request.getParameter("eventId");
        int eventId = (idStr != null) ? Integer.parseInt(idStr) : 0;

        // 1. Map Form to Model
        Event event = new Event();
        if (eventId > 0) event.setEventID(eventId);
        
        event.setEventTitle(request.getParameter("title"));
        event.setDescription(request.getParameter("description"));
        event.setEventVenue(request.getParameter("venue"));
        event.setEventDate(Date.valueOf(request.getParameter("date")));
        
        // Ensure time format is HH:mm:ss for SQL
        String startTime = request.getParameter("start_time");
        String endTime = request.getParameter("end_time");
        event.setStartTime(Time.valueOf(startTime.length() == 5 ? startTime + ":00" : startTime));
        event.setEndTime(Time.valueOf(endTime.length() == 5 ? endTime + ":00" : endTime));
        
        event.setStatus(request.getParameter("status"));
        event.setMeritPoints(Integer.parseInt(request.getParameter("meritPoints")));
        event.setMaxCapacity(Integer.parseInt(request.getParameter("maxCapacity")));
        event.setOrganizerID(Integer.parseInt(request.getParameter("organizerID")));
        event.setCampusID(request.getParameter("campusID"));
        event.setEventType(request.getParameter("eventType"));

       // 2. Handle Image Upload
        Part filePart = request.getPart("eventImage");
        String fileName = filePart.getSubmittedFileName();
        String finalImageName;

        if (fileName != null && !fileName.isEmpty()) {
            finalImageName = System.currentTimeMillis() + "_" + fileName;

            // Get the base path
            String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "events";

            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs(); 

            // FIX START: Instead of filePart.write(), use an InputStream/OutputStream
            File file = new File(uploadPath, finalImageName);
            try (java.io.InputStream input = filePart.getInputStream();
                 java.io.FileOutputStream output = new java.io.FileOutputStream(file)) {

                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
            } 
            

        } else {
            finalImageName = request.getParameter("existingImage");
            if (finalImageName == null || finalImageName.isEmpty()) {
                finalImageName = "empty_image.jpg";
            }
        }
        event.setImageURL(finalImageName);

       // 3. Save to Database
        
        int finalId = eventId;
        boolean success;

        if ("update".equals(action)) {
            success = dao.updateEvent(event);
        } else {
            finalId = dao.addEvent(event); // Capture the new ID
            success = (finalId > 0);
        }

        if (success) {
            // Redirect to the detail page so they see their changes!
            response.sendRedirect("event-details.jsp?id=" + finalId + "&status=success");
        } else {
            response.sendRedirect("manage_event.jsp?status=error");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("delete".equals(action) && idStr != null) {
            int eventId = Integer.parseInt(idStr);
            EventDAO dao = new EventDAO();

            // Optional: Delete the image file from the folder too
            Event e = dao.getEventById(eventId);
            if (e != null && !e.getImageURL().equals("placeholder.png")) {
                String path = getServletContext().getRealPath("/") + "assets/images/events/" + e.getImageURL();
                new File(path).delete();
            }

            boolean success = dao.deleteEvent(eventId); // You'll need this method in DAO
            response.sendRedirect("ad_event.jsp?status=" + (success ? "deleted" : "error"));
        }
    }
}