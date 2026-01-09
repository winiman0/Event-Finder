package com.event.controller;

import com.event.dao.UserDAO;
import com.event.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/UpdateProfileServlet")
public class UpdateProfileServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 1. Get data from the Modal Form
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String faculty = request.getParameter("faculty");

        // 2. Update the User object
        currentUser.setFullName(fullName);
        currentUser.setEmail(email);
        currentUser.setPhoneNumber(phone);
        currentUser.setFaculty(faculty);

        // 3. Save to Database
        UserDAO dao = new UserDAO();
        boolean updated = dao.updateProfile(currentUser);

        if (updated) {
            User freshUser = dao.getUserByID(currentUser.getUserID());
            session.setAttribute("user", freshUser); 
            response.sendRedirect("profile.jsp?status=success");
        
        } else {
            response.sendRedirect("profile.jsp?status=error");
        }
    }
}