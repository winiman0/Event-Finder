package com.event.util;

import java.sql.Connection;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class DBConnection {
    public static Connection getConnection() {
        Connection conn = null;
        try {
            // This is the "JNDI Lookup" that finds your resource
            InitialContext ctx = new InitialContext();
            DataSource ds = (DataSource) ctx.lookup("java:app/jdbc/EventFinderDB");
            conn = ds.getConnection();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return conn;
    }
}