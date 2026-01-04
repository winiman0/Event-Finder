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

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Get data from form
        User newUser = new User();
        newUser.setUserID(request.getParameter("studentID"));
        newUser.setFullName(request.getParameter("fullname"));
        newUser.setEmail(request.getParameter("email"));
        newUser.setPassword(request.getParameter("password"));
        newUser.setCampusID(request.getParameter("campus"));

        // 2. Call DAO
        UserDAO dao = new UserDAO();
        if (dao.registerUser(newUser)) {
            // Success: Go to login
            response.sendRedirect("login.jsp?msg=success");
        } else {
            // Fail: Stay here
            request.setAttribute("error", "Registration Failed. Try again.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}