/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.event.controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
/**
 *
 * @author User
 */
@WebServlet("/getImage")
public class ImageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String imageName = request.getParameter("name");

        // 1. Define the External Path (where user uploads go)
        String realPath = getServletContext().getRealPath("/");
        File projectRoot = new File(realPath).getParentFile().getParentFile();
        File externalFile = new File(projectRoot, "external_uploads" + File.separator + imageName);

        File finalFile = null;

        if (externalFile.exists() && !externalFile.isDirectory()) {
            // Option A: The file is in the external folder
            finalFile = externalFile;
        } else {
            // Option B: Fallback to the internal project folder (assets/images/events/)
            String internalPath = getServletContext().getRealPath("/assets/images/events/" + imageName);
            File internalFile = new File(internalPath);

            if (internalFile.exists()) {
                finalFile = internalFile;
            } else {
                // Option C: Hard fallback to the "empty_image.png" if everything else fails
                String defaultPath = getServletContext().getRealPath("/assets/images/empty_image.png");
                finalFile = new File(defaultPath);
            }
        }

        // Serve the file
        if (finalFile != null && finalFile.exists()) {
            String contentType = getServletContext().getMimeType(finalFile.getName());
            response.setContentType(contentType != null ? contentType : "image/jpeg");
            Files.copy(finalFile.toPath(), response.getOutputStream());
        }
    }
}
