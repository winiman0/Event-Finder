<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.event.model.Event" %>
<%@ page import="com.event.dao.EventDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.time.*" %>

<%
    request.setAttribute("activePage", "home");
    EventDAO eventDao = new EventDAO();
    eventDao.syncEventStatuses(); // Ensure statuses are up to date
    
    // 1. Get All Events
    List<Event> allEvents = eventDao.getAllEvents();
    if(allEvents == null) allEvents = new ArrayList<>();
    
    // 2. Find the TRUE "Next Event" (Must be 'Upcoming')
    Event nextEvent = null;
    for(Event e : allEvents) {
        if ("Upcoming".equalsIgnoreCase(e.getStatus())) {
            nextEvent = e;
            break; // Stop at the first (closest) upcoming event
        }
    }
    
    // 3. Calculate targetMillis for the countdown
    long targetMillis = 0;
    if (nextEvent != null) {
        try {
            java.sql.Date d = nextEvent.getEventDate();
            java.sql.Time t = nextEvent.getStartTime();
            
            if (d != null && t != null) {
                // Combine Date and Time correctly
                String combined = d.toString() + " " + t.toString();
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                targetMillis = sdf.parse(combined).getTime();
            } else if (d != null) {
                targetMillis = d.getTime();
            }
        } catch (Exception e) {
            targetMillis = 0;
        }
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
        <div class="preloader-inner"><span class="dot"></span><div class="dots"><span></span><span></span><span></span></div></div>
    </div>
    
    <%@ include file="header.jsp" %>

    <div class="main-banner">
        <div class="counter-content">
            <ul>
                <li>Days<span id="timer-days">0</span></li>
                <li>Hours<span id="timer-hours">0</span></li>
                <li>Minutes<span id="timer-minutes">0</span></li>
                <li>Seconds<span id="timer-seconds">0</span></li>
            </ul>
        </div>
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="main-content">
                        <div class="next-show">
                            <i class="fa fa-arrow-up"></i>
                            <span>Next Upcoming Event</span>
                        </div>
                        <% if (nextEvent != null) { %>
                            <h6>Opening on <%= nextEvent.getEventDate() %> at <%= nextEvent.getStartTime() %></h6>
                            <h2><%= nextEvent.getEventTitle() %></h2>
                            <div class="main-white-button">
                                <a href="event-details.jsp?id=<%= nextEvent.getEventID() %>">Join the Night!</a>
                            </div>
                        <% } else { %>
                            <h2>Stay Tuned for Future Events!</h2>
                            <p style="color:white;">No upcoming events scheduled at the moment.</p>
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
                        <% for(Event e : allEvents) { %>
                            <div class="item">
                                <a href="event-details.jsp?id=<%= e.getEventID() %>">
                                    <img src="${pageContext.request.contextPath}/getImage?name=<%= e.getImageURL() %>" 
                                         alt="Event Image" onerror="this.src='assets/images/empty_image.png';"
                                         style="width:100%; height:250px; object-fit:cover;">
                                </a>
                            </div>
                        <% } %>
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
                        Earn merit points, build your network, and never miss out on the action again. Check out the latest in <a href="ad_event.jsp">Shows & Events</a>.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="coming-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-heading"><h2>Latest Events</h2></div>
                </div>
                <% 
                   int count = 0;
                   for(Event e : allEvents) { 
                       if(count++ == 3) break; 
                %>
                <div class="col-lg-4">
                    <div class="event-item">
                        <div class="thumb">
                            <a href="event-details.jsp?id=<%= e.getEventID() %>">
                                <img src="getImage?name=<%= e.getImageURL() %>" style="height: 350px; object-fit: cover;" onerror="this.src='assets/images/empty_image.png';">
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
                <div class="col-lg-12 text-center">
                    <p>Copyright 2025 Digitific Company</p>
                </div>
            </div>
        </div>
    </footer>

    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/owl-carousel.js"></script>
    <script src="assets/js/custom.js"></script>
    
    <script>
        // Preloader fallback
        setTimeout(function(){
            document.getElementById('js-preloader').classList.add('loaded');
        }, 1500);

        // Countdown Logic
        var countToTimestamp = <%= targetMillis %>;

        function updateCounter() {
            if (countToTimestamp <= 0) {
                setCounterValues(0, 0, 0, 0);
                return;
            }

            var now = new Date().getTime();
            var diff = countToTimestamp - now;

            if (diff <= 0) {
                setCounterValues(0, 0, 0, 0);
                return;
            }

            var d = Math.floor(diff / (1000 * 60 * 60 * 24));
            var h = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var m = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            var s = Math.floor((diff % (1000 * 60)) / 1000);

            setCounterValues(d, h, m, s);
        }

        function setCounterValues(d, h, m, s) {
            document.getElementById("timer-days").innerText = d;
            document.getElementById("timer-hours").innerText = h;
            document.getElementById("timer-minutes").innerText = m;
            document.getElementById("timer-seconds").innerText = s;
        }

        setInterval(updateCounter, 1000);
        updateCounter();
    </script>
</body>
</html>