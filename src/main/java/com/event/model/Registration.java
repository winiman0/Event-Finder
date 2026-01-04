package com.event.model;
import java.sql.Timestamp;

public class Registration {
    private int regID;
    private String userID;
    private int eventID;
    private Timestamp regDate;

    public Registration() {}

    // Getters and Setters
    public int getRegID() { return regID; }
    public void setRegID(int regID) { this.regID = regID; }
    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }
    public int getEventID() { return eventID; }
    public void setEventID(int eventID) { this.eventID = eventID; }
    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
}