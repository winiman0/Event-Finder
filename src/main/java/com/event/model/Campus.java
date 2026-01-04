package com.event.model;

public class Campus {
    private String campusID;
    private String campusName;
    private String campusState;

    public Campus() {}

    // Getters and Setters
    public String getCampusID() { return campusID; }
    public void setCampusID(String campusID) { this.campusID = campusID; }
    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }
    public String getCampusState() { return campusState; }
    public void setCampusState(String campusState) { this.campusState = campusState; }
}