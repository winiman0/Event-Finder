package com.event.controller;

import com.event.dao.EventDAO;
import com.event.model.Event;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;

@WebServlet("/EventServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, maxFileSize = 1024 * 1024 * 10, maxRequestSize = 1024 * 1024 * 50)
public class EventServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        EventDAO dao = new EventDAO();
        String action = request.getParameter("action");
        String idStr = request.getParameter("eventId");
        int eventId = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : 0;

        if ("updateStatus".equals(action)) {
            String newStatus = request.getParameter("status");

            boolean success = dao.updateEventStatus(eventId, newStatus);

            // Redirect back to details page
            response.sendRedirect("event-details.jsp?id=" + eventId + "&msg=" + (success ? "statusUpdated" : "error"));
            return; // Stop execution here so it doesn't try to run the code below
        }
        // 1. Map Form to Model
        Event event = new Event();
        if (eventId > 0) event.setEventID(eventId);
        
        event.setEventTitle(request.getParameter("title"));
        event.setDescription(request.getParameter("description"));
        event.setEventVenue(request.getParameter("venue"));
        event.setEventDate(Date.valueOf(request.getParameter("date")));
        
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

            String realPath = getServletContext().getRealPath("/");
            File projectRoot = new File(realPath).getParentFile().getParentFile();
            File uploadDir = new File(projectRoot, "external_uploads");

            if (!uploadDir.exists()) uploadDir.mkdirs(); 

            File file = new File(uploadDir, finalImageName);
            try (java.io.InputStream input = filePart.getInputStream();
                 java.io.FileOutputStream output = new java.io.FileOutputStream(file)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    output.write(buffer, 0, bytesRead);
                }
            } 
        } else {
            String existingImage = request.getParameter("existingImage");
            if (existingImage != null && !existingImage.isEmpty()) {
                finalImageName = existingImage;
            } else {
                finalImageName = "empty_image.png"; 
            }
        }
        event.setImageURL(finalImageName);
        
        // 3. Save to Database
        int finalId = eventId;
        boolean success;

        if ("update".equals(action)) {
            success = dao.updateEvent(event);
        } else {
            finalId = dao.addEvent(event); 
            success = (finalId > 0);
        }

        if (success) {
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
            Event e = dao.getEventById(eventId);
            
            if (e != null && e.getImageURL() != null && !e.getImageURL().equals("empty_image.png")) {
         
                String realPath = getServletContext().getRealPath("/");
                File projectRoot = new File(realPath).getParentFile().getParentFile();
                File file = new File(projectRoot, "external_uploads" + File.separator + e.getImageURL());
                
                if(file.exists()) file.delete();
            }

            boolean success = dao.deleteEvent(eventId);
            response.sendRedirect("ad_event.jsp?status=" + (success ? "deleted" : "error"));
        }
    }
} 