package com.event.listener;

import com.event.dao.EventDAO;
import jakarta.servlet.ServletContextListener; 
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class EventStatusScheduler implements ServletContextListener {
    
    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // This runs when the server starts
        scheduler = Executors.newSingleThreadScheduledExecutor();
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println("[Background Task] Checking for expired events...");
                new EventDAO().syncEventStatuses();
            } catch (Exception e) {
                System.err.println("Error in background sync: " + e.getMessage());
            }
        }, 0, 1, TimeUnit.HOURS); 
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // This stops the background task when the server stops
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
    }
}