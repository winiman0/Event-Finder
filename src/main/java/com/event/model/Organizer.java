package com.event.model;

public class Organizer {
    private int organizerID;
    private String campusID;
    private String organizerName;
    private String organizerType;
    private String organizerDetail;

    // Getters and Setters
    public int getOrganizerID() { return organizerID; }
    public void setOrganizerID(int organizerID) { this.organizerID = organizerID; }
    
    public String getCampusID() {return campusID;}
    public void setCampusID(String campusID) {this.campusID = campusID;}
    
    public String getOrganizerName(){return organizerName;}
    public void setOrganizerName(String organizerName) {this.organizerName=organizerName;}
    
    public String getOrganizerType() {return organizerType;}
    public void setOrganizerType(String organizerType){this.organizerType = organizerType;}
    
    public String getOrganizerDetail() {return organizerDetail;}
    public void setOrganizerDetail(String organizerDetail) {this.organizerDetail=organizerDetail;}
    
}