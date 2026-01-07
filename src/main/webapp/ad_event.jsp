<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User, com.event.model.Event, com.event.dao.EventDAO, com.event.dao.RegistrationDAO, java.util.*"%>
<%@page import="java.time.LocalDate, java.time.format.DateTimeFormatter"%>
<%
    // Data Fetching
    User user = (User) session.getAttribute("user"); 
    
    // 1. Initialize the DAOs
    EventDAO dao = new EventDAO();
    RegistrationDAO regDao = new RegistrationDAO(); 
    
    boolean isAdmin = (user != null && "admin".equalsIgnoreCase(user.getRole()));
    List<Event> events = (dao.getAllEvents() != null) ? dao.getAllEvents() : new ArrayList<>();
    LocalDate today = LocalDate.now();
    List<String> allCampuses = dao.getAllCampusesFromTable(); 
    
    String[] eventTypes = {"Club Activity", "Gathering", "Workshop", "Talk", "Volunteering", "Meeting", "Competition (General)", "Trip", "Ceremony", "Entrepreneurship", "Arts and Performance", "Seminar", "Sports (Competitive)", "Sports (Recreational)", "Exhibition"};
    request.setAttribute("activePage", "events");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Digitific | Manage Events</title>
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <style>
        /* This fix ensures the grey background covers the whole area */
        .main-content-wrapper {
            background-color: #f7f7f7; /* The light grey background */
            min-height: 100vh;
            padding-top: 50px;
            padding-bottom: 80px;
        }
        .sidebar { 
            background: #fff; 
            border-radius: 15px; 
            border: none;
            position: sticky;
            top: 100px;
        }
        .nav-pills .nav-link.active {
            background-color: #2a2a2a;
        }
        .nav-pills .nav-link {
            color: #666;
            font-weight: 600;
        }
        .empty-placeholder {
            background: #fff;
            border: 2px dashed #ddd;
            border-radius: 15px;
            padding: 50px;
            text-align: center;
            color: #999;
        }
        .event-card { margin-bottom: 25px; }
        .event-item { 
            background: #fff; 
            border: 1px dashed #ddd;
            display: flex;
            align-items: stretch;
            overflow: hidden;
        }
        .event-content-left { padding: 30px; flex: 1; border-right: 1px solid #eee; }
        .event-image-center { flex: 1; min-width: 300px; }
        .event-image-center img { width: 100%; height: 100%; object-fit: cover; }
        .event-info-right { padding: 30px; flex: 1; border-left: 1px solid #eee; display: flex; flex-direction: column; justify-content: center; }
        
        .event-content-left h3 { font-weight: 700; margin-bottom: 15px; font-size: 24px; }
        .event-content-left p { color: #777; line-height: 1.6; margin-bottom: 25px; }
        
        .info-row { display: flex; align-items: flex-start; margin-bottom: 20px; font-size: 15px; color: #333; }
        .info-row i { margin-right: 15px; margin-top: 4px; color: #333; width: 20px; text-align: center; }
        .info-row strong { display: block; font-size: 18px; margin-bottom: 2px; }
        
        .btn-event { 
            background-color: #2a2a2a; 
            color: #fff; 
            padding: 12px 25px; 
            text-transform: uppercase; 
            font-weight: 700; 
            font-size: 13px; 
            display: inline-block;
            border: none;
            transition: 0.3s;
        }
        .btn-event:hover { background-color: #ff5622; color: #fff; }

        .nav-pills .nav-link.active { background-color: #2a2a2a; }
        .empty-placeholder { background: #fff; border: 2px dashed #ddd; border-radius: 15px; padding: 50px; text-align: center; color: #999; }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>
    <div class="page-heading-shows-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>Our Shows & Events</h2>
                    <span>Manage your upcoming and past events here.</span>
                </div>
            </div>
        </div>
    </div>

    <div class="main-content-wrapper">
        <div class="container">
            <div class="row">
                
                <div class="col-lg-3">
                    <div class="sidebar card shadow-sm p-4">
                        <h5 class="mb-4">Filter Events</h5>
                        <form id="filterForm">
                            <div class="filter-group mb-4">
                                <h6 class="small text-uppercase font-weight-bold text-muted">Branch Campus</h6>
                                <% for(String campus : allCampuses) { %>
                                    <div class="form-check mb-1">
                                        <input class="form-check-input campus-filter" type="checkbox" value="<%= campus %>" id="chk_<%= campus %>">
                                        <label class="form-check-label" for="chk_<%= campus %>"><%= campus %></label>
                                    </div>
                                <% } %>
                            </div>

                            <div class="filter-group mb-4">
                                <h6 class="small text-uppercase font-weight-bold text-muted">Event Type</h6>
                                <select class="form-control form-control-sm" id="typeFilter">
                                    <option value="all">All Types</option>
                                    <% for(String type : eventTypes) { %>
                                        <option value="<%= type %>"><%= type %></option>
                                    <% } %>
                                </select>
                            </div>

                            <div class="filter-group mb-4">
                                <h6 class="small text-uppercase font-weight-bold text-muted">Extra Features</h6>
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="meritFilter">
                                    <label class="form-check-label" for="meritFilter">Merit Only</label>
                                </div>
                            </div>

                            <button type="button" class="btn btn-sm btn-outline-danger w-100" onclick="resetFilters()">Clear All</button>
                        </form>
                    </div>
                </div>

                <div class="col-lg-9">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <ul class="nav nav-pills" id="eventTabs" role="tablist">
                            <li class="nav-item">
                                <a class="nav-link active" id="upcoming-tab" data-toggle="pill" href="#upcoming" role="tab">Upcoming</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" id="past-tab" data-toggle="pill" href="#past" role="tab">Past</a>
                            </li>
                        </ul>
                        <% if (isAdmin) { %>
                            <div class="main-dark-button"><a href="manage_event.jsp">Add Event</a></div>
                        <% } %>
                    </div>

                    <div class="tab-content" id="pills-tabContent">
                        
                        <div class="tab-pane fade show active" id="upcoming" role="tabpanel">
                            <div class="row event-container">
                                <% 
                                boolean hasUpcoming = false;
                                for(Event e : events) {
                                    if (!e.getEventDate().toLocalDate().isBefore(today)) { 
                                        hasUpcoming = true; 
                                        int confirmedCount = regDao.getConfirmedCount(e.getEventID());
                                    %>
                                        <div class="col-lg-12 event-card" 
                                             data-campus="<%= e.getEventVenue() %>" 
                                             data-type="<%= e.getEventType() %>" 
                                             data-merit="<%= e.getMeritPoints() > 0 %>">
                                            <div class="event-item">
                                                <div class="event-content-left">
                                                    <h3><%= e.getEventTitle() %></h3>
                                                    <p><%= (e.getDescription().length() > 100) ? e.getDescription().substring(0, 100) + "..." : e.getDescription() %></p>
                                                    
                                                    <a href="event-details.jsp?id=<%= e.getEventID() %>" class="btn-event">
                                                        <%= isAdmin ? "Edit Event" : "View Details" %>
                                                    </a>
                                                </div>

                                                <div class="event-image-center">
                                                    <img src="assets/images/events/<%= e.getImageURL() %>" alt="<%= e.getEventTitle() %>">
                                                </div>

                                                <div class="event-info-right">
                                                    <div class="info-row">
                                                        <i class="fa fa-clock-o"></i>
                                                        <div>
                                                            <strong><%= e.getEventDate().toLocalDate().format(DateTimeFormatter.ofPattern("MMM dd")) %></strong>
                                                            <% 
                                                                DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("hh:mm a"); 
                                                             %>
                                                            <span><%= e.getStartTime() %> - <%= e.getEndTime() %></span>
                                                        </div>
                                                    </div>
                                                    <div class="info-row">
                                                        <i class="fa fa-map-marker"></i>
                                                        <div><%= e.getEventVenue() %></div>
                                                    </div>
                                                    <div class="info-row">
                                                        <i class="fa fa-users"></i>
                                                        <div><%= confirmedCount %> Guests Attending</div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                <% } } 
                                if (!hasUpcoming) { %>
                                    <div class="col-12"><div class="empty-placeholder"><h3>No upcoming events.</h3><p>Time to create one!</p></div></div>
                                <% } %>
                            </div>
                        </div>

                        <div class="tab-pane fade" id="past" role="tabpanel">
                            <div class="row event-container">
                                <% 
                                boolean hasPast = false;
                                for(Event e : events) {
                                    if (e.getEventDate().toLocalDate().isBefore(today)) { 
                                        hasPast = true; 
                                        int confirmedCount = regDao.getConfirmedCount(e.getEventID());
                                        %>
                                        <div class="col-lg-12 event-card" style="opacity: 0.7;"
                                             data-campus="<%= e.getEventVenue() %>" 
                                             data-type="<%= e.getEventType() %>" 
                                             data-merit="<%= e.getMeritPoints() > 0 %>">
                                            <div class="event-item">
                                                <div class="row align-items-center">
                                                    <div class="col-md-8">
                                                        <h4 class="text-muted"><%= e.getEventTitle() %></h4>
                                                        <p class="small">Completed on: <%= e.getEventDate() %></p>
                                                        <p class="small"><i class="fa fa-users"></i> <%= confirmedCount %> Total Attendees</p>
                                                    </div>
                                                    <div class="col-md-4 text-right">
                                                        <span class="badge badge-secondary p-2">Archive</span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                <% } } 
                                if (!hasPast) { %>
                                    <div class="col-12"><div class="empty-placeholder"><h3>Archive is empty.</h3></div></div>
                                <% } %>
                            </div>
                        </div>

                    </div> </div> </div>
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

    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script>
        // Use the same filter function you already had
        function filterEvents() {
            const selectedCampuses = Array.from(document.querySelectorAll('.campus-filter:checked')).map(cb => cb.value);
            const selectedType = document.getElementById('typeFilter').value;
            const meritOnly = document.getElementById('meritFilter').checked;

            document.querySelectorAll('.event-card').forEach(card => {
                const cardCampus = card.getAttribute('data-campus');
                const cardType = card.getAttribute('data-type');
                const hasMerit = card.getAttribute('data-merit') === 'true';

                let show = true;
                if (selectedCampuses.length > 0 && !selectedCampuses.includes(cardCampus)) show = false;
                if (selectedType !== 'all' && cardType !== selectedType) show = false;
                if (meritOnly && !hasMerit) show = false;

                card.style.display = show ? "block" : "none";
            });
        }

        document.querySelectorAll('.form-check-input, #typeFilter').forEach(input => {
            input.addEventListener('change', filterEvents);
        });

        function resetFilters() {
            document.getElementById('filterForm').reset();
            filterEvents();
        }
    </script>
</body>
</html>