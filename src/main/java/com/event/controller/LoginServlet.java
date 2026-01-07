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

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Get data from the JSP form
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String redirectPath = request.getParameter("redirect");

        // 2. Call the DAO to check database
        UserDAO userDAO = new UserDAO();
        User user = userDAO.authenticateUser(email, password);

        if (user != null) {
            //System.out.println("DEBUG: User logged in with role: [" + user.getRole() + "]"); 
  
            // 3. Login success: Create a session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            
            if (redirectPath != null && !redirectPath.isEmpty()) {
                response.sendRedirect(redirectPath);
            }
            // 4. Redirect based on role (Admin vs Student)
            if ("admin".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect("admin_dashboard.jsp");
            } else {
                response.sendRedirect("index.jsp");
            }
        } else {
            // 5. Login failed: Send back to login with error
            request.setAttribute("errorMessage", "Invalid Email or Password");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}