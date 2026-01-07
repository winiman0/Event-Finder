<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User, com.event.model.Event, java.util.List, java.util.ArrayList"%>
<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Initialize DAOs
    com.event.dao.EventDAO dao = new com.event.dao.EventDAO();
    com.event.dao.UserDAO userDao = new com.event.dao.UserDAO();

    // Fetch Stats
    int totalEvents = dao.getCount("EVENT");
    int totalStudents = userDao.getStudentCount(); 
    int totalRegs = dao.getCount("REGISTRATION");

    List<Event> events = dao.getAllEvents();
    if (events == null) events = new ArrayList<>();

    request.setAttribute("activePage", "dashboard");
%>
<% request.setAttribute("activePage", "dashboard"); %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Tooplate">
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i&display=swap" rel="stylesheet">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css' rel='stylesheet' />
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js'></script>
    <script src="https://unpkg.com/@popperjs/core@2"></script>
    <script src="https://unpkg.com/tippy.js@6"></script>
    <title>Dashboard</title>


    <!-- Additional CSS Files -->
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">

    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">

    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">

    <style>
    body {
        background-color: #f2f2fe; 
        min-height: 100vh;
    }

    .dashboard-container {
        max-width: 1100px;
        margin: 40px auto;
    }

    .stats-boxes {
        display: flex;
        gap: 25px;
        margin-bottom: 40px;
    }

    .stat-card {
            background: #fff;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            width: 30%;
            transition: transform 0.3s;
            border-bottom: 4px solid #fb3f3f; /* Digitific Red Accent */
        }
        .stat-card:hover { transform: translateY(-5px); }
        .stat-card li { font-size: 16px; color: #666; font-weight: 500; }
        .stat-card span { 
            display: block; 
            font-size: 32px; 
            color: #2a2a2a; 
            font-weight: 700; 
            margin-top: 10px; 
        }

    .stat-card h4 {
        font-size: 18px;
        margin-bottom: 10px;
        color: #3B0270;
    }

    .stat-number {
        font-size: 40px;
        margin-top: 5px;
        font-weight: bold;
        color: #413b4d;
    }

    .stat-card a {
        display: inline-block;
        color: #fff;
        padding: 12px 18px;
        margin-right: 15px;
        border-radius: 8px;
        text-decoration: none;
        font-size: 14px;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 15px;
        border-radius: 10px;
        overflow: hidden;
        background-color: #fdfdf9; /* very light cream */
    }

    th, td {
        padding: 14px 16px;
        text-align: left;
    }

    th {
        background-color: #e8e2f5; /* soft off-white for header */
        font-weight: bold;
    }

    tr:nth-child(even) {
        background-color: #f2effa; /* subtle difference for alternating rows */
    }

    tr:nth-child(odd) {
        background-color: #f9f7fc; 
    }
    
    
    .fc-event {
        cursor: pointer;
        background-color: #fb3f3f !important; /* Your Digitific Red */
        border: none !important;
    }
    #calendar {
        max-width: 900px;
        margin: 0 auto;
    }

    .admin-calendar-wrapper {
            background: white; padding: 30px; border-radius: 15px; 
            box-shadow: 0px 10px 30px rgba(0,0,0,0.1); margin-bottom: 50px;
        }
        .fc-event { cursor: pointer; border: none !important; padding: 2px 5px; }
        .fc-button-primary { background-color: #2a2a2a !important; border: none !important; }
        .fc-button-primary:hover { background-color: #fb3f3f !important; }

        /* Table Styling */
        .report-table {
            width: 100%; background: white; border-radius: 15px; overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-top: 20px;
        }
        .report-table th { background: #2a2a2a; color: white; padding: 15px; }
        .report-table td { padding: 15px; border-bottom: 1px solid #eee; }
        
    .tooltip-inner {
        background-color: #2a2a2a !important;
        color: #fff;
        padding: 10px 15px;
        border-radius: 8px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        text-align: left;
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
        <%@ include file="header.jsp" %>
    
    <div class="dashboard-container">
        
        <div class="container-fluid">
            <div class="page-heading-rent-venue">
            <div class="col-lg-12">
                    <div class="section-heading">
                        <h2>Admin Dashboard</h2><br>
                    </div>
            </div>
        </div>
        <div class="counter-content dashboard-counter">
        <ul>
            <div class="stat-card"><li>Total Events<span id="stat-upcoming"><%= totalEvents %></span></li></div>
            <div class="stat-card"><li>Total Students<span id="stat-week"><%= totalStudents %></span></li></div>
            <div class="stat-card"><li>Event Registrations<span id="stat-joined"><%= totalRegs %></span></li></div>
        </ul>

        </div>
        <!-- calendar -->
        <div class="container mt-5">
            <div class="row">
                <div class="col-lg-12">
                    <div class="section-heading">
                        <h2>Event Schedule Overview</h2>
                        <span>Global view of all system events</span>
                    </div>
                    <div class="admin-calendar-wrapper">
                        <div id='calendar'></div>
                    </div>
                </div>
            </div>
        </div>
        <!-- TABLE -->
        <div class="section-heading">
            <h2>Registrations Per Event</h2>
        </div>

        <table>
            <tr>
                <th>Event Name</th>
                <th>Total Registrations</th>
            </tr>
            <%
                java.util.List<String[]> report = dao.getRegistrationsPerEvent();
                if (report == null || report.isEmpty()) {
            %>
                <tr>
                    <td colspan="2" style="text-align: center; padding: 30px; color: #888;">
                        <i class="fa fa-info-circle"></i> There are currently no registrations to display.
                    </td>
                </tr>
            <%
                } else {
                    for(String[] row : report) {
            %>
                <tr>
                    <td><strong><%= row[0] %></strong></td>
                    <td><span class="badge badge-danger" style="background:#fb3f3f;"><%= row[1] %> Joined</span></td>
                </tr>
            <% 
                    } 
                } 
            %>
        </table>

    </div>
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
                    <%-- Loop through ALL events fetched by EventDAO --%>
                    <% for(Event e : events) { %>
                    {
                        id: '<%= e.getEventID() %>',
                        title: '<%= e.getEventTitle().replace("'", "\\'") %>',
                        start: '<%= e.getEventDate() %>T<%= e.getStartTime() %>',
                        end: '<%= e.getEventDate() %>T<%= e.getEndTime() %>',
                        extendedProps: {
                            venue: '<%= e.getEventVenue().replace("'", "\\'") %>',
                            type: '<%= e.getEventType() %>'
                        },
                        backgroundColor: '#fb3f3f', // Admin default to Brand Red
                        borderColor: '#fb3f3f',
                        url: 'event-details.jsp?id=<%= e.getEventID() %>'
                    },
                    <% } %>
                ],

                // This handles the "Pretty" Tooltip on Hover
                eventDidMount: function(info) {
                    $(info.el).tooltip({
                        title: "<strong>" + info.event.title + "</strong><br>" +
                               "<small><i class='fa fa-tag'></i> " + info.event.extendedProps.type + "</small><br>" +
                               "<i class='fa fa-map-marker'></i> " + info.event.extendedProps.venue,
                        placement: 'top',
                        trigger: 'hover',
                        container: 'body',
                        html: true
                    });
                },

                eventClick: function(info) {
                    if (info.event.url) {
                        window.location.href = info.event.url;
                        info.jsEvent.preventDefault();
                    }
                }
            });
            calendar.render();
        });
        </script> 
</body>
</html>
