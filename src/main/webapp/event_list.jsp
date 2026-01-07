<%-- 
    Document   : event_list
    Created on : Jan 6, 2026, 11:49:23 PM
    Author     : User
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.Event, com.event.model.User, com.event.dao.RegistrationDAO, java.util.List"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    RegistrationDAO regDao = new RegistrationDAO();
    List<Event> upcomingEvents = regDao.getEventsByUser(user.getUserID(), true);
    List<Event> pastEvents = regDao.getEventsByUser(user.getUserID(), false);
    
    int upcomingCount = regDao.getCountByUser(user.getUserID(), "upcoming");
    int weekCount = regDao.getCountByUser(user.getUserID(), "week");
    int totalJoined = regDao.getCountByUser(user.getUserID(), "total");
    
    //Calendar 
    List<Event> allMyEvents = new java.util.ArrayList<>();
    allMyEvents.addAll(upcomingEvents);
    allMyEvents.addAll(pastEvents);
    
    request.setAttribute("activePage", "myevents");
%>
<%@ include file="header.jsp" %>
<!DOCTYPE html>
<html lang="en">

  <head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Tooplate">
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i&display=swap" rel="stylesheet">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />

    <title>Digitific: Your Events</title>


    <!-- Additional CSS Files -->
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">

    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">

    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
<!--

Tooplate 2125 ArtXibition

https://www.tooplate.com/view/2125-artxibition

-->

    <style>
        .fc-event { cursor: pointer; border: none; padding: 2px 5px; }
        .fc-toolbar-title { color: #2a2a2a; font-weight: 700; }
        .fc-button-primary { background-color: #fb3f3f !important; border: none !important; }
        .fc-daygrid-event-dot { border-color: #fb3f3f !important; }
        .tooltip-inner {
            background-color: #2a2a2a !important; /* Dark background */
            color: #fff;
            padding: 10px 15px;
            border-radius: 8px;
            font-size: 13px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        .bs-tooltip-top .arrow::before, .bs-tooltip-auto[x-placement^="top"] .arrow::before {
            border-top-color: #2a2a2a !important;
        }
    </style>
    </head>
    
    <body>
    <!-- ***** Preloader Start ***** -->
    <div id="js-preloader" class="js-preloader">
      <div class="preloader-inner">
        <span class="dot"></span>
        <div class="dots">
          <span></span>
          <span></span>
          <span></span>
        </div>
      </div>
    </div>
    <!-- ***** Preloader End ***** -->

    <!-- ***** About Us Page ***** -->
    <div class="page-heading-rent-venue">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>Your Events</h2>
                    <span>Check out your events.</span>
                </div>
            </div>
        </div>
    </div>

    <div class="shows-events-schedule">
        <!-- USER DASHBOARD -->
        <div class="counter-content dashboard-counter">
        <ul>
            <li>Upcoming<span id="stat-upcoming"><%= upcomingCount %></span></li>
            <li>This Week<span id="stat-week"><%= weekCount %></span></li>
            <li>Total Joined<span id="stat-joined"><%= totalJoined %></span></li>
        </ul>
    </div>

    <div class="container mt-5 mb-5">
        <div class="row">
            <div class="col-lg-12">
                <div id='calendar-container' style="background: white; padding: 20px; border-radius: 15px; box-shadow: 0px 10px 30px rgba(0,0,0,0.1);">
                    <div id='calendar'></div>
                </div>
            </div>
        </div>
    </div>
    <!-- ***** Main Banner Area End ***** -->
    <section class="user-dashboard section" id="user-dashboard">
        <div class="container">
            <div class="row">
                <!-- Upcoming Events (User Joined) -->
                <div class="section-heading">
                            <h2>Your Upcoming Event</h2>
                </div>
                <div class="col-lg-12">
                        <ul>
                            <% if(upcomingEvents.isEmpty()) { %>
                                <p class="text-center">No upcoming events. <a href="shows-events.jsp">Browse events here!</a></p>
                            <% } else { 
                                for(Event e : upcomingEvents) { %>
                            <li>
                                <div class="row">
                                    <div class="col-lg-3">
                                        <div class="title">
                                            <h4><%= e.getEventTitle() %></h4>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="time"><span><i class="fa fa-clock-o"></i> <%= e.getEventDate() %><br><%= e.getStartTime() %> to <%= e.getEndTime() %></span></div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="place"><span><i class="fa fa-map-marker"></i><%= e.getEventVenue() %></span></div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="place"><span>Merit: <%= e.getMeritPoints() %></span></div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="main-dark-button">
                                            <a href="event-details.jsp?id=<%= e.getEventID() %>" class="main-white-button">View Details</a>
                                            <% if ("Waiting".equalsIgnoreCase(e.getStatus())) { %>
                                                <span class="status-badge" style="background: #ffc107; color: #000; padding: 5px 10px; border-radius: 20px; font-size: 12px; margin-left: 10px;">
                                                    <i class="fa fa-hourglass-half"></i> Waitlisted
                                                </span>
                                            <% } else { %>
                                                <span class="status-badge" style="background: #28a745; color: #fff; padding: 5px 10px; border-radius: 20px; font-size: 12px; margin-left: 10px;">
                                                    <i class="fa fa-check"></i> Confirmed
                                                </span>
                                            <% } %>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                            <div class="main-dark-button">
                                                <a href="event-details.jsp?id=<%= e.getEventID() %>" class="main-white-button">View Details</a>
                                                <span class="status joined">Registered</span>
                                            </div>
                                        </div>
                                </div>
                            </li>
                            <% } } %>
                        </ul>
                    </div>
                <!-- Past Events -->
                <div class="section-heading">
                <h2>Past Events</h2>
                </div>
                <div class="col-lg-12">
                        <ul style="opacity: 0.7;"> <% for(Event e : pastEvents) { %>
                            <li>
                                <div class="row">
                                    <div class="col-lg-3">
                                        <div class="title">
                                            <h4><%= e.getEventTitle() %></h4>
                                        </div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="time"><span><i class="fa fa-clock-o"></i> <%= e.getEventDate() %></span></div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="place"><span><i class="fa fa-map-marker"></i> <%= e.getEventVenue() %></span></div>
                                    </div>
                                    <div class="col-lg-3">
                                        <div class="place"><span>Merit: <%= e.getMeritPoints() %></span></div>
                                    </div>
                                </div>
                            </li>
                            <% } %>
                        </ul>
                    </div>
            </div>
        </div>
    </section>

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
                                            <li><a href="index.html" class="active">Home</a></li>
                                            <li><a href="about.html">About Us</a></li>
                                            <li><a href="shows-events.html">Shows & Events</a></li> 
                                        </ul>
                                    </div>
                                </div>
                                <div class="col-lg-3">
                                    <div class="social-links">
                                        <ul>
                                            <li><a href="https://www.facebook.com/uitmrasmi/?locale=ms_MY"><i class="fa fa-facebook"></i></a></li>
                                            <li><a href="https://www.instagram.com/uitm.official/"><i class="fa fa-instagram"></i></a></li>
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
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        var calendarEl = document.getElementById('calendar');
        var calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek'
            },
            events: [
                <% for(Event e : allMyEvents) { %>
                {
                    id: '<%= e.getEventID() %>',
                    title: '<%= e.getEventTitle().replace("'", "\\'") %>',
                    start: '<%= e.getEventDate() %>T<%= e.getStartTime() %>',
                    end: '<%= e.getEventDate() %>T<%= e.getEndTime() %>',
                    extendedProps: {
                        venue: '<%= e.getEventVenue().replace("'", "\\'") %>'
                    },
                    backgroundColor: '<%= "Waiting".equalsIgnoreCase(e.getStatus()) ? "#ffc107" : "#fb3f3f" %>',
                    borderColor: '<%= "Waiting".equalsIgnoreCase(e.getStatus()) ? "#ffc107" : "#fb3f3f" %>',
                    textColor: '<%= "Waiting".equalsIgnoreCase(e.getStatus()) ? "#000" : "#fff" %>',
                    url: 'event-details.jsp?id=<%= e.getEventID() %>'
                },
                <% } %>
            ],
           
            eventClick: function(info) {
                // This makes the calendar dots clickable
                if (info.event.url) {
                    window.location.href = info.event.url;
                    info.jsEvent.preventDefault(); // Prevents browser following link in new tab
                }
            },
            // Show summary on hover/touch
            eventDidMount: function(info) {
                // This creates the Bootstrap tooltip
                $(info.el).tooltip({
                    title: "<strong>" + info.event.title + "</strong><br><i class='fa fa-map-marker'></i> " + info.event.extendedProps.venue,
                    placement: 'top',
                    trigger: 'hover',
                    container: 'body',
                    html: true // This allows us to use <strong> and <br> tags
                });
            },
        });
        calendar.render();
    });
    </script>
  </body>

</html>
