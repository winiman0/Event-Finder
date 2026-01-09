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
    
    // 1. Get All Events first (for the carousel/pictures)
    List<Event> allEvents = eventDao.getAllEvents();
    if(allEvents == null) allEvents = new ArrayList<>(); // Prevent null pointer
    
    // 2. Get the closest event for the counter
    Event closestEvent = eventDao.getClosestEvent(); 
    
    // 3. Set nextEvent logic
    Event nextEvent = (!allEvents.isEmpty()) ? allEvents.get(0) : null;
    
    // 4. Calculate targetMillis safely
    long targetMillis = 0;
    if (closestEvent != null && closestEvent.getEventDate() != null) {
        try {
            // We use the Date + Time from the object
            java.sql.Date d = closestEvent.getEventDate();
            java.sql.Time t = closestEvent.getStartTime();
            
            if (t != null) {
                // Combine date and time into one timestamp
                String combined = d.toString() + " " + t.toString();
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                targetMillis = sdf.parse(combined).getTime();
            } else {
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
                <li>Days<span id="timer-days"></span></li>
                <li>Hours<span id="timer-hours"></span></li>
                <li>Minutes<span id="timer-minutes"></span></li>
                <li>Seconds<span id="timer-seconds"></span></li>
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
                                    <img src="${pageContext.request.contextPath}/getImage?name=<%= e.getImageURL() %>" 
                                                alt="Event Image" 
                                                style="width:100%; height:250px; object-fit:cover;">
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
                                <img src="getImage?name=<%= e.getImageURL() %>" 
                                     alt="<%= e.getEventTitle() %>" 
                                     style="height: 350px; object-fit: cover;">
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

   <!-- *** Footer *** -->
    <footer>
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="under-footer">
                        <div class="rowFooter">
                            <div class="col-lg-6 col-sm-6 ms-auto text-end">
                                <p class="copyright">Copyright 2025 Digitific Company 
                    
                    			<br>Design: <a rel="nofollow" href="https://www.tooplate.com" target="_parent">Tooplate</a></p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-12">
                    <div class="sub-footer">
                        <div class="row">
                            <div class="col-lg-3">
                                <div class="logo"><span><em>Digitific</em></span></div>
                            </div>
                            <div class="col-lg-6">
                                <div class="menu">
                                    <ul>
                                        <li><a href="index.jsp" class="active">Home</a></li>
                                        <li><a href="ad_event.jsp">Shows & Events</a></li> 
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
        // Force preloader off after 2 seconds no matter what
        setTimeout(function(){
            document.getElementById('js-preloader').classList.add('loaded');
        }, 2000);
    </script>
    <script>
        var countToTimestamp = <%= targetMillis %>;
        console.log("Target Event Timestamp:", countToTimestamp); // Debugging line

        function updateCounter() {
            if (countToTimestamp === 0) {
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
            
            var dEl = document.getElementById("timer-days");
            var hEl = document.getElementById("timer-hours");
            var mEl = document.getElementById("timer-minutes");
            var sEl = document.getElementById("timer-seconds");

            if(dEl) dEl.innerText = d;
            if(hEl) hEl.innerText = h;
            if(mEl) mEl.innerText = m;
            if(sEl) sEl.innerText = s;
        }
        // This clear interval trick helps stop some flickering if the 
        // template's custom.js is poorly written
        var counterInterval = setInterval(updateCounter, 1000);
        updateCounter();
    </script>
    </body>
</html>
