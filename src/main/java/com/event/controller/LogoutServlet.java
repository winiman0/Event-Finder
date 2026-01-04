package com.event.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LogoutServlet", urlPatterns = {"/LogoutServlet"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get the current session (do not create a new one)
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // 2. Destroy the session and all its data (clears the 'user' attribute)
            session.invalidate();
        }
        
        // 3. Send the user back to the login page with a success message
        response.sendRedirect("login.jsp?message=loggedout");
    }
}