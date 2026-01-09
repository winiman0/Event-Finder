package com.event.model;

import java.io.Serializable;

public class User implements Serializable {
    private String userID;
    private String fullName;
    private String email;
    private String password;
    private String role;
    private String campusID;
    private String phoneNumber;
    private String faculty;
    private String campusName;
    private String campusState;

    // 1. Constructor (Empty)
    public User() {}

    // 2. Getters and Setters (Right-click -> Insert Code -> Getter and Setter in NetBeans)
    public String getUserID() { return userID; }
    public void setUserID(String userID) { this.userID = userID; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getCampusID() { return campusID; }
    public void setCampusID(String campusID) { this.campusID = campusID; }
    
    public String getPhoneNumber() {return phoneNumber;}
    public void setPhoneNumber(String phoneNumber) {this.phoneNumber=phoneNumber;}
    
    public String getFaculty() {return faculty;}
    public void setFaculty(String faculty){this.faculty=faculty;}
    
    public String getCampusName() { return campusName; }
    public void setCampusName(String campusName) { this.campusName = campusName; }
    
    public String getCampusState() { return campusState; }
    public void setCampusState(String campusState) { this.campusState = campusState; }

}