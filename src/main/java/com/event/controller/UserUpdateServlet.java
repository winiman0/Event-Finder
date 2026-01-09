package com.event.controller;

import com.event.dao.UserDAO;
import com.event.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/UserUpdateServlet")
public class UserUpdateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Capture data from the Modal form
            String userId = request.getParameter("userId");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String campusId = request.getParameter("campus"); // This is the ID
            String faculty = request.getParameter("faculty");
            String role = request.getParameter("role");

            // DEBUG: Check your NetBeans Output window!
            System.out.println("Updating User: " + userId);
            System.out.println("Campus ID received: " + campusId);

            // 2. Map data to the User model
            User user = new User();
            user.setUserID(userId);
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhoneNumber(phone);
            user.setCampusID(campusId);
            user.setFaculty(faculty);
            user.setRole(role);

            // 3. Call DAO
            UserDAO dao = new UserDAO();
            boolean success = dao.updateUserByAdmin(user);

            if (success) {
                response.sendRedirect("users.jsp?msg=updated");
            } else {
                response.sendRedirect("users.jsp?msg=error");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("users.jsp?msg=error");
        }
    }
}