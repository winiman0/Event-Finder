package com.event.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Time;

public class Event implements Serializable {
    private int eventID;
    private int organizerID;
    private String eventTitle;
    private String description;
    private String eventType;
    private String eventVenue;
    private Date eventDate;
    private Time startTime;
    private Time endTime;
    private String status;
    private String imageURL;

    public Event() {}

    // Getters and Setters matching your SQL exactly
    public int getEventID() { return eventID; }
    public void setEventID(int eventID) { this.eventID = eventID; }

    public int getOrganizerID() { return organizerID; }
    public void setOrganizerID(int organizerID) { this.organizerID = organizerID; }

    public String getEventTitle() { return eventTitle; }
    public void setEventTitle(String eventTitle) { this.eventTitle = eventTitle; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }

    public String getEventVenue() { return eventVenue; }
    public void setEventVenue(String eventVenue) { this.eventVenue = eventVenue; }

    public Date getEventDate() { return eventDate; }
    public void setEventDate(Date eventDate) { this.eventDate = eventDate; }

    public Time getStartTime() { return startTime; }
    public void setStartTime(Time startTime) { this.startTime = startTime; }

    public Time getEndTime() { return endTime; }
    public void setEndTime(Time endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getImageURL() { return imageURL; }
    public void setImageURL(String imageURL) { this.imageURL = imageURL; }
}