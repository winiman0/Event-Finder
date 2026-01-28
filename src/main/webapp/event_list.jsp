<%-- 
    Document   : event_list
    Created on : Jan 6, 2026
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.Event, com.event.model.User, com.event.dao.RegistrationDAO, java.util.List, java.util.ArrayList"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    RegistrationDAO regDao = new RegistrationDAO();
    
    // 1. Fetch data from DAO
    List<Event> rawUpcoming = regDao.getEventsByUser(user.getUserID(), true);
    List<Event> pastEventsRaw = regDao.getEventsByUser(user.getUserID(), false);
    List<Event> allWaitingRaw = regDao.getWaitingListByUser(user.getUserID()); 
    
    // 2. Initialize our clean lists
    List<Event> upcomingEvents = new ArrayList<>(); 
    List<Event> waitingEvents = new ArrayList<>();  
    List<Event> pastEvents = new ArrayList<>(pastEventsRaw); 
    List<Event> pastWaitlist = new ArrayList<>();
    
    java.time.LocalDate today = java.time.LocalDate.now();
    
    // 3. Filter the 'Upcoming' list to only include Confirmed ones
    for(Event e : rawUpcoming) {
        String status = e.getStatus();
        // Allow both Confirmed AND Cancelled to pass through to the calendar
        if("Confirmed".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status)) {
            upcomingEvents.add(e);
        }
    }
    
    // 4. Sort the Waitlist into Future or Past
    for(Event e : allWaitingRaw) {
        java.time.LocalDate eventDate = e.getEventDate().toLocalDate(); 
        if(eventDate.isBefore(today)) { 
            pastWaitlist.add(e);; 
        } else { 
            waitingEvents.add(e); 
        }
    }

   // 5. Update Counters
    int upcomingCount = upcomingEvents.size();
    int waitingCount = waitingEvents.size();

    int totalJoined = pastEventsRaw.size() + pastWaitlist.size();

    // 6. Combine for Calendar 
    List<Event> allMyEvents = new ArrayList<>();
    allMyEvents.addAll(upcomingEvents);
    allMyEvents.addAll(pastEventsRaw); // Confirmed 
    allMyEvents.addAll(waitingEvents);  // Future 
    allMyEvents.addAll(pastWaitlist);   // Past 

    request.setAttribute("activePage", "myevents");
%>
<%@ include file="header.jsp" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Digitific | Dashboard</title>
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <link href='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.css' rel='stylesheet' />
    
    <style>
        body { background-color: rgba(124, 107, 142, 1) !important; overflow-x: hidden; }

        /* THE GLASS DASHBOARD */
        .glass-panel {
            background: rgba(255, 255, 255, 0.04);
            backdrop-filter: blur(25px);
            -webkit-backdrop-filter: blur(25px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 30px;
            padding: 25px;
            height: 100%;
            box-shadow: 0 20px 40px rgba(0,0,0,0.4);
        }

        #calendar-container { background: #ffffff; border-radius: 20px; padding: 20px; height: 750px; }

        .control-panel-title {
            color: white;
            letter-spacing: 2px;
            font-size: 23px;
            font-weight: 800;
            margin-bottom: 20px;
            display: block;
        }

        /* STAT CARDS */
        .stat-stack { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; margin-bottom: 30px; }
        .stat-card {
            background: rgba(255, 255, 255, 0.07);
            border: 1px solid rgba(255, 255, 255, 0.1);
            padding: 15px;
            border-radius: 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-align: center;
        }
        .stat-card:hover { border-color: #DDFF7F; background: rgba(255,255,255,0.12); }
        .stat-card.active { background: rgba(221, 255, 127, 0.1); border: 2px solid #DDFF7F; }
        .stat-card label { color: #eee; font-size: 10px; text-transform: uppercase; display: block; cursor: pointer; margin-bottom: 5px; }
        .stat-card span { color: #DDFF7F; font-size: 24px; font-weight: 800; display: block; }

        /* SCROLLABLE LIST */
        .scroll-list { height: 430px; overflow-y: auto; padding-right: 8px; }
        .scroll-list::-webkit-scrollbar { width: 4px; }
        .scroll-list::-webkit-scrollbar-thumb { background: rgba(221, 255, 127, 0.3); border-radius: 10px; }

        .event-mini-card {
            background: #ffffff;
            border-radius: 15px;
            padding: 15px;
            margin-bottom: 12px;
            display: block;
            text-decoration: none !important;
            transition: 0.2s;
        }
        .event-mini-card:hover { transform: translateX(5px); background: #fdfdfd; }
        .event-mini-card h5 { font-size: 14px; font-weight: 700; color: #333; margin: 0; }
        .event-mini-card p { font-size: 11px; color: #777; margin: 0; }
        
        .empty-state {
            background: rgba(255,255,255,0.05);
            border: 1px dashed rgba(255,255,255,0.7);
            color: white;
            padding: 20px;
            border-radius: 15px;
            text-align: center;
            font-size: 13px;
        }
        /* Makes the text in cancelled calendar events have a strikethrough */
.event-cancelled .fc-event-title {
    text-decoration: line-through;
    opacity: 0.6;
}
        .badge-neon { background: #DDFF7F; color: #2D1B4E; font-size: 10px; padding: 4px 10px; border-radius: 10px; font-weight: 700; }
    </style>
</head>

<body>
    <div class="page-heading-rent-venue">
        <div class="container">
            <h2>Your Events</h2>
            <span>Manage your schedule and history in one place.</span>
        </div>
    </div>

    <div class="container-fluid mt-4 px-4 pb-5">
        <div class="row g-4">
            <div class="col-lg-8">
                <div class="glass-panel">
                   
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h2 style="color: white; font-weight: 800; margin:0;">Event Calendar</h2>
                        <span class="badge-neon">LIVE VIEW</span>
                    </div>
                    <div id='calendar-container'>
                        <div id='calendar'></div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="glass-panel">
                    <span class="control-panel-title">Activity Overview</span>
                    
                    <div class="stat-stack">
                        <div class="stat-card active" onclick="filterList('upcoming', this)">
                            <label>Upcoming</label>
                            <span><%= upcomingCount %></span>
                        </div>
                        <div class="stat-card" onclick="filterList('waiting', this)">
                            <label>Waitlist</label>
                            <span><%= waitingCount %></span>
                        </div>
                        <div class="stat-card" onclick="filterList('all', this)" style="grid-column: span 2;">
                            <label>Total Experience / History</label>
                            <span><%= totalJoined %></span>
                        </div>
                    </div>

                    <span class="control-panel-title" id="list-title">Upcoming Schedule</span>
                    
                    <div class="scroll-list" id="event-list">
                        
                        <div class="list-section" id="upcoming-section">
                            <% if(upcomingEvents.isEmpty()) { %>
                                <div class="empty-state">No upcoming events found.</div>
                            <% } else { for(Event e : upcomingEvents) { 
                                String status = e.getStatus();
                                String badgeClass = "badge-success";
                                if("Cancelled".equalsIgnoreCase(status)) badgeClass = "badge-danger";
                            %>
                                <a href="event-details.jsp?id=<%= e.getEventID() %>" class="event-mini-card">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <h5><%= e.getEventTitle() %></h5>
                                            <p><i class="fa fa-calendar"></i> <%= e.getEventDate() %></p>
                                        </div>
                                        <span class="badge <%= badgeClass %>" style="font-size: 9px;"><%= status %></span>
                                    </div>
                                </a>
                            <% } } %>
                        </div>

                        <div class="list-section" id="waiting-section" style="display:none;">
                            <% if(waitingEvents.isEmpty()) { %>
                                <div class="empty-state">No active waitlists.</div>
                            <% } else { for(Event e : waitingEvents) { %>
                                <a href="event-details.jsp?id=<%= e.getEventID() %>" class="event-mini-card">
                                    <h5><%= e.getEventTitle() %></h5>
                                    <p><i class="fa fa-clock-o"></i> Waitlisted</p>
                                </a>
                            <% } } %>
                        </div>

                        <div class="list-section" id="history-section" style="display:none;">
                        <% 
                            
                            List<Event> historyList = new ArrayList<>(pastEventsRaw);
                            historyList.addAll(pastWaitlist);

                            if(historyList.isEmpty()) { %>
                            <div class="empty-state">No past event history.</div>
                        <% } else { for(Event e : historyList) { 
                            boolean wasConfirmed = pastEventsRaw.contains(e);
                            boolean wasVerified = "Attended".equalsIgnoreCase(e.getStatus());
                        %>
                            <a href="event-details.jsp?id=<%= e.getEventID() %>" class="event-mini-card" style="<%= !wasConfirmed ? "opacity: 0.7;" : "" %>">
                                <h5><%= e.getEventTitle() %></h5>
                                <p>
                                    <% if(wasVerified) { %>
                                        <span class="badge badge-success">Points Earned: +<%= e.getMeritPoints() %></span>
                                    <% } else if (wasConfirmed) { %>
                                        <span class="badge badge-secondary">Absent / Not Verified</span>
                                    <% } else { %>
                                        <span class="badge badge-dark">Waitlist Expired</span>
                                    <% } %>
                                    | <%= e.getEventDate() %>
                                </p>
                            </a>
                        <% } } %>
                    </div>

                    </div>
                </div>
            </div>
        </div>
    </div>

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

    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src='https://cdn.jsdelivr.net/npm/fullcalendar@5.11.3/main.min.js'></script>

    <script>
        function filterList(type, el) {
            $('.stat-card').removeClass('active');
            $(el).addClass('active');
            $('.list-section').hide();
            
            if(type === 'upcoming') {
                $('#list-title').text('Upcoming Schedule');
                $('#upcoming-section').fadeIn();
            } else if(type === 'waiting') {
                $('#list-title').text('Waitlist Status');
                $('#waiting-section').fadeIn();
            } else {
                $('#list-title').text('Event History');
                $('#history-section').fadeIn();
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                height: '100%',
                headerToolbar: { left: 'prev,next today', center: 'title', right: 'dayGridMonth,timeGridWeek' },
                events: [
                    <% for(int i = 0; i < allMyEvents.size(); i++) { 
                        Event e = allMyEvents.get(i);
                        // .trim() handles hidden spaces, .toUpperCase() handles casing
                        String status = (e.getStatus() != null) ? e.getStatus().trim().toUpperCase() : "";

                        String bgColor = "#4D2B8C"; // Default Purple
                        String titlePrefix = "";
                        
                        if (status.equals("CANCELLED")) {
                            bgColor = "#D3D3D3"; // Grey
                            titlePrefix = "🚫 ";
                        } else if (status.equals("WAITING")) {
                            bgColor = "#FFD700"; // Gold
                        }
                    %>
                    {
                        id: '<%= e.getEventID() %>',
                        title: '<%= titlePrefix + e.getEventTitle().replace("'", "\\'") %>',
                        start: '<%= e.getEventDate() %>',
                        backgroundColor: '<%= bgColor %>',
                        borderColor: 'transparent',
                        textColor: '<%= status.equals("CANCELLED") ? "#666666" : "#FFFFFF" %>',
                        classNames: ['<%= status.equals("CANCELLED") ? "event-cancelled" : "" %>']
                    }<%= (i < allMyEvents.size() - 1) ? "," : "" %>
                    <% } %>
                ],
                eventClick: function(info) { window.location.href = "event-details.jsp?id=" + info.event.id; }
            });
            calendar.render();
        });
    </script>
</body>
</html>