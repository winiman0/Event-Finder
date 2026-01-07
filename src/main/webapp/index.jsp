<%-- 
    Document   : index
    Created on : Jan 7, 2026, 12:48:21 AM
    Author     : User
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.event.model.Event" %>
<%@ page import="com.event.dao.EventDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%
    request.setAttribute("activePage", "home");
    EventDAO eventDao = new EventDAO();
    
    // 1. Get the closest upcoming event for the Counter and Banner
    Event closestEvent = eventDao.getClosestEvent(); 
    
    // 2. Get all events - CHANGED NAME TO allEvents TO MATCH YOUR LOOPS
    List<Event> allEvents = eventDao.getAllEvents();
    
    // 3. Set the nextEvent using the list we just fetched
    Event nextEvent = (allEvents != null && !allEvents.isEmpty()) ? allEvents.get(0) : null;
    
    // 4. Handle the target date for the counter
    String targetDate = "Dec 31, 2026 23:59:59"; // Default fallback
    if (closestEvent != null) {
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd, yyyy HH:mm:ss");
        targetDate = sdf.format(closestEvent.getEventDate()) + " " + closestEvent.getStartTime();
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Digitific | Home</title>

    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    </head>
    <body>
        <div id="js-preloader" class="js-preloader">
      <div class="preloader-inner">
        <span class="dot"></span>
        <div class="dots">
          <span></span><span></span><span></span>
        </div>
      </div>
    </div>
    
    <%-- DYNAMIC HEADER INCLUDE --%>
    <%@ include file="header.jsp" %>

    <div class="main-banner">
        <div class="counter-content">
            <ul>
                <li>Days<span id="days"></span></li>
                <li>Hours<span id="hours"></span></li>
                <li>Minutes<span id="minutes"></span></li>
                <li>Seconds<span id="seconds"></span></li>
            </ul>
        </div>
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="main-content">
                        <div class="next-show">
                            <i class="fa fa-arrow-up"></i>
                            <span>Next Event</span>
                        </div>
                        <% if (nextEvent != null) { %>
                            <h6>Opening on <%= nextEvent.getEventDate() %></h6>
                            <h2><%= nextEvent.getEventTitle() %></h2>
                            <div class="main-white-button">
                                <a href="event-details.jsp?id=<%= nextEvent.getEventID() %>">Join the Night!</a>
                            </div>
                        <% } else { %>
                            <h2>Stay Tuned for Events!</h2>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="show-events-carousel">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="owl-show-events owl-carousel">
                        <% if (allEvents != null) { 
                            for(Event e : allEvents) { %>
                            <div class="item">
                                <a href="event-details.jsp?id=<%= e.getEventID() %>">
                                    <img src="assets/images/events/<%= e.getImageURL() %>" alt="<%= e.getEventTitle() %>" style="height: 350px; object-fit: cover;">
                                </a>
                            </div>
                        <% } } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
                    
    <div class="amazing-venues">
        <div class="container">
            <div class="row">
                <div class="col-lg-9">
                    <div class="left-content">
                        <h4>Discover Events Across UiTM Campuses</h4>
                        <p>Digitific is your central hub for all campus activities. From <strong>UiTM Shah Alam</strong> to <strong>UiTM Dungun</strong>, we bring every club, society, and organization event to your fingertips. 
                        <br><br>
                        Earn merit points, build your network, and never miss out on the action again. Check out the latest in <a href="shows-events.jsp">Shows & Events</a>.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="coming-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-heading">
                        <h2>Latest Events</h2>
                    </div>
                </div>
                
                <%-- LOOP THROUGH TOP 3 EVENTS --%>
                <% 
                   int count = 0;
                   for(Event e : allEvents) { 
                       if(count++ == 3) break; // Only show first 3
                %>
                <div class="col-lg-4">
                    <div class="event-item">
                        <div class="thumb">
                            <a href="event-details.jsp?id=<%= e.getEventID() %>">
                                <img src="assets/images/events/<%= e.getImageURL() %>" alt="<%= e.getEventTitle() %>" style="height: 250px; object-fit: cover;">
                            </a>
                        </div>
                        <div class="down-content">
                            <a href="event-details.jsp?id=<%= e.getEventID() %>"><h4><%= e.getEventTitle() %></h4></a>
                            <ul>
                                <li><i class="fa fa-clock-o"></i> <%= e.getEventDate() %></li>
                                <li><i class="fa fa-map-marker"></i> <%= e.getEventVenue() %></li>
                            </ul>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <footer>
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="sub-footer">
                        <div class="row">
                            <div class="col-lg-6">
                                <div class="menu">
                                    <ul>
                                        <li><a href="index.jsp" class="active">Home</a></li>
                                        <li><a href="shows-events.jsp">Shows & Events</a></li> 
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </footer>

     <!-- jQuery -->
    <script src="assets/js/jquery-2.1.0.min.js"></script>

    <!-- Bootstrap -->
    <script src="assets/js/popper.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>

    <!-- Plugins -->
    <script src="assets/js/scrollreveal.min.js"></script>
    <script src="assets/js/waypoints.min.js"></script>
    <script src="assets/js/jquery.counterup.min.js"></script>
    <script src="assets/js/imgfix.min.js"></script> 
    <script src="assets/js/mixitup.js"></script> 
    <script src="assets/js/accordions.js"></script>
    <script src="assets/js/owl-carousel.js"></script>
    
    <!-- Global Init -->
    <script src="assets/js/custom.js"></script>

        <script>
            // Overriding the hardcoded date from custom.js
            var eventTargetDate = "<%= targetDate %>";

            function updateCounter() {
                var countTo = new Date(eventTargetDate).getTime();
                var now = new Date().getTime();
                var diff = countTo - now;

                if (diff < 0) return; // Event has passed

                var d = Math.floor(diff / (1000 * 60 * 60 * 24));
                var h = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                var m = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                var s = Math.floor((diff % (1000 * 60)) / 1000);

                document.getElementById("days").innerHTML = d;
                document.getElementById("hours").innerHTML = h;
                document.getElementById("minutes").innerHTML = m;
                document.getElementById("seconds").innerHTML = s;
            }
            setInterval(updateCounter, 1000);
        </script>
    </body>
</html>
