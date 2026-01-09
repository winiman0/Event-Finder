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
  
    
    String[] eventTypes = {"Club Activity", "Gathering", "Workshop", "Talk", "Volunteering", "Meeting", "Competition (General)", "Trip", "Ceremony", "Entrepreneurship", "Arts/Performance", "Seminar", "Sports (Competitive)", "Sports (Recreational)", "Exhibition"};
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
        .event-badges {
            margin-bottom: 10px;
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        .badge-item {
            padding: 5px 12px;
            border-radius: 15px;
            font-size: 11px;
            text-transform: uppercase;
            font-weight: 600;
        }
        .bg-campus { background-color: #e3f2fd; color: #0d47a1; } /* Light Blue */
        .bg-type { background-color: #f3e5f5; color: #7b1fa2; }   /* Light Purple */
        .bg-merit { background-color: #e8f5e9; color: #2e7d32; }  /* Light Green */

        /* Status Badge Colors */
        .bg-upcoming { background-color: #007bff; color: #fff; }  /* Blue */
        .bg-ongoing { background-color: #28a745; color: #fff; }   /* Green */
        .bg-completed { background-color: #6c757d; color: #fff; } /* Grey */
        .bg-cancelled { background-color: #dc3545; color: #fff; } /* Red */

        /* Status indicator dot */
        .status-dot {
            height: 8px;
            width: 8px;
            border-radius: 50%;
            display: inline-block;
            margin-right: 5px;
        }
        @media (max-width: 768px) {
    .event-item {
        flex-direction: column;
    }
    .event-image-center {
        min-width: 100%;
        height: 200px;
    }
}
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
                            <div class="filter-group mb-4">
                                <h6 class="small text-uppercase font-weight-bold text-muted">Status</h6>
                                <div class="form-check mb-1">
                                    <input class="form-check-input status-filter" type="checkbox" value="upcoming" id="stat_upcoming">
                                    <label class="form-check-label" for="stat_upcoming">Upcoming</label>
                                </div>
                                <div class="form-check mb-1">
                                    <input class="form-check-input status-filter" type="checkbox" value="ongoing" id="stat_ongoing">
                                    <label class="form-check-label" for="stat_ongoing">Ongoing</label>
                                </div>
                                <div class="form-check mb-1">
                                    <input class="form-check-input status-filter" type="checkbox" value="completed" id="stat_completed">
                                    <label class="form-check-label" for="stat_completed">Completed</label>
                                </div>
                                <div class="form-check mb-1">
                                    <input class="form-check-input status-filter" type="checkbox" value="cancelled" id="stat_cancelled">
                                    <label class="form-check-label" for="stat_cancelled">Cancelled</label>
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
    
                    <%-- SUCCESS/UPCOMING TAB --%>
                    <div class="tab-pane fade show active" id="upcoming" role="tabpanel">
                        <div class="row event-container">
                            <% 
                            boolean hasUpcoming = false;
                            for(Event e : events) {
                                if (!e.getEventDate().toLocalDate().isBefore(today)) { 
                                    hasUpcoming = true;
                                    String displayStatus = e.getStatus();
                                    if (e.getEventDate().toLocalDate().equals(today)) {
                                        displayStatus = "Ongoing";
                                    }
                                    int confirmedCount = regDao.getConfirmedCount(e.getEventID());
                                        String imageName = (e.getImageURL() == null || e.getImageURL().isEmpty()) ? "empty_image.png" : e.getImageURL();
                                        String imgPath = request.getContextPath() + "/getImage?name=" + imageName;
                            %>
                                <div class="col-lg-12 event-card" 
                                     data-campus="<%= e.getCampusName() %>" 
                                     data-type="<%= e.getEventType() %>" 
                                     data-merit="<%= e.getMeritPoints() > 0 %>"
                                     data-status="<%= e.getStatus().toLowerCase() %>">
                                    <div class="event-item">
                                        <div class="event-content-left">
                                            <h3><%= e.getEventTitle() %></h3>
                                            <div class="event-badges">
                                                <span class="badge-item bg-<%= e.getStatus().toLowerCase() %>">
                                                    <span class="status-dot"></span> <%= e.getStatus().toUpperCase() %>
                                                </span>
                                                <% if(e.getCampusName() != null) { %><span class="badge-item bg-campus"><i class="fa fa-university"></i> <%= e.getCampusName() %></span><% } %>
                                                <% if(e.getEventType() != null) { %><span class="badge-item bg-type"><%= e.getEventType() %></span><% } %>
                                                <% if(e.getMeritPoints() > 0) { %><span class="badge-item bg-merit"><i class="fa fa-star"></i> <%= e.getMeritPoints() %> Merit</span><% } %>
                                            </div>
                                            <p><%= (e.getDescription().length() > 100) ? e.getDescription().substring(0, 100) + "..." : e.getDescription() %></p>
                                            <a href="event-details.jsp?id=<%= e.getEventID() %>" class="btn-event">
                                                <%= isAdmin ? "Manage Event" : "View Details" %>
                                            </a>
                                        </div>

                                        <div class="event-image-center">
                                            <img src="<%= imgPath %>" onerror="this.src='assets/images/empty_image.png';" alt="Event">
                                        </div>

                                        <div class="event-info-right">
                                            <div class="info-row">
                                                <i class="fa fa-clock-o"></i>
                                                <div>
                                                    <strong><%= e.getEventDate().toLocalDate().format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) %></strong>
                                                    <span><%= e.getStartTime() %> - <%= e.getEndTime() %></span>
                                                </div>
                                            </div>
                                            <div class="info-row">
                                                <i class="fa fa-map-marker"></i>
                                                <div><strong><%= e.getEventVenue() %></strong></div>
                                            </div>
                                            <div class="info-row">
                                                <i class="fa fa-users"></i>
                                                <div><%= confirmedCount %> / <%= e.getMaxCapacity() %> Attending</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            <% } } 
                            if (!hasUpcoming) { %>
                                <div class="col-12"><div class="empty-placeholder"><h3>No upcoming events found.</h3></div></div>
                            <% } %>
                        </div>
                    </div>

                    <%-- PAST TAB (Now using the same layout) --%>
                    <div class="tab-pane fade" id="past" role="tabpanel">
                        <div class="row event-container">
                            <% 
                            boolean hasPast = false;
                            for(Event e : events) {
                                if (e.getEventDate().toLocalDate().isBefore(today)) { 
                                    hasPast = true; 
                                    String displayStatus = e.getStatus();
                                    if (e.getEventDate().toLocalDate().equals(today)) {
                                        displayStatus = "Ongoing";
                                    }
                                    int confirmedCount = regDao.getConfirmedCount(e.getEventID());
                                    String imageNamePast = (e.getImageURL() == null || e.getImageURL().isEmpty()) ? "empty_image.png" : e.getImageURL();
                                    String imgPathPast = request.getContextPath() + "/getImage?name=" + imageNamePast;
                            %>
                                <div class="col-lg-12 event-card" style="opacity: 0.8; filter: grayscale(0.5);"
                                     data-campus="<%= e.getCampusName() %>" 
                                     data-type="<%= e.getEventType() %>" 
                                     data-merit="<%= e.getMeritPoints() > 0 %>"
                                     data-status="<%= e.getStatus().toLowerCase() %>">
                                    <div class="event-item">
                                        <div class="event-content-left">
                                            <div class="event-badges">
                                                <span class="badge-item bg-<%= e.getStatus().toLowerCase() %>">
                                                    <span class="status-dot"></span> <%= e.getStatus().toUpperCase() %>
                                                </span>
                                                <% if(e.getCampusName() != null) { %><span class="badge-item bg-campus"><%= e.getCampusName() %></span><% } %>
                                            </div>
                                            <h3><%= e.getEventTitle() %></h3>
                                            <p><%= (e.getDescription().length() > 100) ? e.getDescription().substring(0, 100) + "..." : e.getDescription() %></p>
                                            <a href="event-details.jsp?id=<%= e.getEventID() %>" class="btn-event" style="background-color: #666;">View Archive</a>
                                        </div>

                                        <div class="event-image-center">
                                            <img src="<%= imgPathPast %>" onerror="this.src='assets/images/empty_page.png';" alt="Event">
                                        </div>

                                        <div class="event-info-right">
                                            <div class="info-row"><i class="fa fa-calendar-check-o"></i> <div><strong>Completed</strong><span><%= e.getEventDate() %></span></div></div>
                                            <div class="info-row"><i class="fa fa-users"></i> <div><%= confirmedCount %> Total Participants</div></div>
                                        </div>
                                    </div>
                                </div>
                            <% } } 
                            if (!hasPast) { %>
                                <div class="col-12"><div class="empty-placeholder"><h3>No past events in archive.</h3></div></div>
                            <% } %>
                        </div>
                    </div>
                </div></div> </div>
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

    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script>
        function filterEvents() {
        // 1. Get values from Campus, Type, and Merit
        const selectedCampuses = Array.from(document.querySelectorAll('.campus-filter:checked')).map(cb => cb.value);
        const selectedType = document.getElementById('typeFilter').value;
        const meritOnly = document.getElementById('meritFilter').checked;

        // 2. NEW: Get all checked Statuses (upcoming, ongoing, etc.)
        const selectedStatuses = Array.from(document.querySelectorAll('.status-filter:checked')).map(cb => cb.value);

        document.querySelectorAll('.event-card').forEach(card => {
            const cardCampus = card.getAttribute('data-campus');
            const cardType = card.getAttribute('data-type');
            const hasMerit = card.getAttribute('data-merit') === 'true';
            const cardStatus = card.getAttribute('data-status'); // Get the status

            let show = true;

            // Existing filters
            if (selectedCampuses.length > 0 && !selectedCampuses.includes(cardCampus)) show = false;
            if (selectedType !== 'all' && cardType !== selectedType) show = false;
            if (meritOnly && !hasMerit) show = false;

            // 3. NEW: Status Filter Logic
            // If the user checked any status boxes, hide cards that don't match
            if (selectedStatuses.length > 0 && !selectedStatuses.includes(cardStatus)) {
                show = false;
            }

            card.style.display = show ? "block" : "none";
        });
    }

    // Make sure the status checkboxes trigger the filter too!
    document.querySelectorAll('.status-filter').forEach(input => {
        input.addEventListener('change', filterEvents);
    });
    
    document.querySelectorAll('.campus-filter').forEach(input => {
    input.addEventListener('change', filterEvents);
});

// 3. Event Type dropdown (NEW)
document.getElementById('typeFilter').addEventListener('change', filterEvents);

// 4. Merit checkbox (NEW)
document.getElementById('meritFilter').addEventListener('change', filterEvents);

        function resetFilters() {
            document.getElementById('filterForm').reset();
            filterEvents();
        }
    </script>
</body>
</html>