<%@page contentType="text/html" pageEncoding="UTF-8" import="com.event.model.*, com.event.dao.*, java.util.*, java.time.*, java.time.format.DateTimeFormatter"%>
<%
    User user = (User) session.getAttribute("user");
    EventDAO dao = new EventDAO(); dao.syncEventStatuses();
    RegistrationDAO regDao = new RegistrationDAO();
    boolean isAdmin = (user != null && "admin".equalsIgnoreCase(user.getRole()));
    List<Event> events = (dao.getAllEvents() != null) ? dao.getAllEvents() : new ArrayList<>();
    List<String> allCampuses = dao.getAllCampusesFromTable();
    String[] eventTypes = {"Club Activity", "Gathering", "Workshop", "Talk", "Volunteering", "Meeting", "Competition (General)", "Trip", "Ceremony", "Entrepreneurship", "Arts/Performance", "Seminar", "Sports (Competitive)", "Sports (Recreational)", "Exhibition"};
    LocalDate today = LocalDate.now(); LocalTime now = LocalTime.now();
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
    <link rel="stylesheet" href="assets/css/owl-carousel.css">
    <style>
        .main-content-wrapper { background:#f7f7f7; min-height:100vh; padding: 50px 0 80px; }
        .sidebar { background:#fff; border-radius:15px; position:sticky; top:100px; border:none; }
        .nav-pills .nav-link.active { background:#2a2a2a; }
        .nav-pills .nav-link { color:#666; font-weight:600; }
        .empty-placeholder { background:#fff; border:2px dashed #ddd; border-radius:15px; padding:50px; text-align:center; color:#999; display:none; width:100%; }
        .event-card { margin-bottom:25px; }
        .event-item { background:#fff; border:1px dashed #ddd; display:flex; align-items:stretch; overflow:hidden; }
        .event-content-left, .event-info-right { padding:30px; flex:1; display:flex; flex-direction:column; justify-content:center; }
        .event-content-left { border-right:1px solid #eee; }
        .event-image-center { flex:1; min-width:300px; }
        .event-image-center img { width:100%; height:100%; object-fit:cover; }
        .info-row { display:flex; align-items:flex-start; margin-bottom:20px; font-size:15px; color:#333; }
        .info-row i { margin-right:15px; margin-top:4px; width:20px; text-align:center; color:#333; }
        .info-row strong { display:block; font-size:18px; margin-bottom:2px; }
        .btn-event { background:#2a2a2a; color:#fff; padding:12px 25px; text-transform:uppercase; font-weight:700; font-size:13px; border:none; transition:0.3s; display:inline-block; }
        .btn-event:hover { background:#ff5622; color:#fff; }
        .event-badges { margin-bottom:10px; display:flex; gap:5px; flex-wrap:wrap; }
        .badge-item { padding:5px 12px; border-radius:15px; font-size:11px; text-transform:uppercase; font-weight:600; }
        .bg-campus { background:#e3f2fd; color:#0d47a1; } 
        .bg-merit { background:#e8f5e9; color:#2e7d32; }
        .bg-upcoming { background:#007bff; color:#fff; }
        .bg-ongoing { background:#28a745; color:#fff; } 
        .bg-completed { background:#6c757d; color:#fff; }
        .bg-cancelled { background:#dc3545; color:#fff; }
        .status-dot { height:8px; width:8px; border-radius:50%; display:inline-block; margin-right:5px; background:#fff; }
        @media (max-width: 768px) { .event-item { flex-direction:column; } .event-image-center { min-width:100%; height:200px; } }
    </style>
</head>
<body>
<%@ include file="header.jsp" %>
    <div class="page-heading-shows-events"><div class="container"><h2>Our Shows & Events</h2><span>Manage your events here.</span></div></div>
    
    <div class="main-content-wrapper"><div class="container"><div class="row">
        <div class="col-lg-3">
            <div class="sidebar card shadow-sm p-4">
                <h5 class="mb-4">Filter Events</h5>
                <form id="filterForm">
                    <div class="filter-group mb-4"><h6 class="small text-uppercase font-weight-bold text-muted">Search Event</h6><input type="text" id="titleSearch" class="form-control form-control-sm" placeholder="Search..." onkeyup="filterEvents()"></div>
                    <div class="filter-group mb-4"><h6 class="small text-uppercase font-weight-bold text-muted">Campus</h6>
                        <% for(String campus : allCampuses) { %>
                            <div class="form-check mb-1"><input class="form-check-input campus-filter" type="checkbox" value="<%= campus %>" id="c_<%= campus %>"><label class="form-check-label" for="c_<%= campus %>"><%= campus %></label></div>
                        <% } %>
                    </div>
                    <div class="filter-group mb-4"><h6 class="small text-uppercase font-weight-bold text-muted">Event Type</h6>
                        <select class="form-control form-control-sm" id="typeFilter" onchange="filterEvents()"><option value="all">All Types</option>
                            <% for(String type : eventTypes) { %><option value="<%= type %>"><%= type %></option><% } %>
                        </select>
                    </div>
                    <button type="button" class="btn btn-sm btn-outline-danger w-100" onclick="resetFilters()">Clear All</button>
                </form>
            </div>
        </div>

        <div class="col-lg-9">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <ul class="nav nav-pills" id="eventTabs">
                    <li class="nav-item"><a class="nav-link active" data-toggle="pill" href="#upcoming">Upcoming</a></li>
                    <li class="nav-item"><a class="nav-link" data-toggle="pill" href="#past">Past</a></li>
                </ul>
                <div class="d-flex align-items-center">
                    <select id="sortEvents" class="form-control form-control-sm mr-3" onchange="sortEvents()"><option value="date-asc">Soonest</option><option value="date-desc">Latest</option><option value="title-asc">A-Z</option></select>
                    <% if (isAdmin) { %><div class="main-dark-button"><a href="manage_event.jsp">+</a></div><% } %>
                </div>
            </div>

            <div class="tab-content">
                <% String[] panes = {"upcoming", "past"};
                   for(String pane : panes) { %>
                <div class="tab-pane fade <%= pane.equals("upcoming")?"show active":"" %>" id="<%= pane %>">
                    <div class="row event-container">
                        
                        <div class="empty-placeholder" id="empty-<%= pane %>">
                            <i class="fa fa-search fa-3x mb-3"></i>
                            <h3><%= pane.equals("upcoming") ? "No upcoming events found" : "Archive is empty" %></h3>
                            <p>Try adjusting your filters or search keywords.</p>
                        </div>

                        <% for(Event e : events) {
                               LocalDate eDate = e.getEventDate().toLocalDate();
                               LocalTime eStart = e.getStartTime().toLocalTime();
                               LocalTime eEnd = e.getEndTime().toLocalTime();
                               
                               boolean isPhysPast = eDate.isBefore(today) || (eDate.equals(today) && now.isAfter(eEnd));
                               String status = (e.getStatus() != null) ? e.getStatus() : "Upcoming";
                               boolean showPast = isPhysPast || "Completed".equalsIgnoreCase(status) || "Cancelled".equalsIgnoreCase(status);

                               if ((pane.equals("upcoming") && !showPast) || (pane.equals("past") && showPast)) {
                                   if (pane.equals("upcoming") && eDate.equals(today) && now.isAfter(eStart) && now.isBefore(eEnd)) status = "Ongoing";
                                   String img = (e.getImageURL() == null || e.getImageURL().isEmpty()) ? "empty_image.png" : e.getImageURL();
                        %>
                        <div class="col-lg-12 event-card" data-date="<%= e.getEventDate() %>" data-title="<%= e.getEventTitle().toLowerCase() %>" data-campus="<%= e.getCampusName() %>" data-type="<%= e.getEventType() %>" data-status="<%= status.toLowerCase() %>">
                            <div class="event-item">
                                <div class="event-content-left">
                                    <h3><%= e.getEventTitle() %></h3>
                                    <div class="event-badges">
                                        <span class="badge-item bg-<%= status.toLowerCase() %>"><span class="status-dot"></span><%= status.toUpperCase() %></span>
                                        <span class="badge-item bg-campus"><i class="fa fa-university"></i> <%= e.getCampusName() %></span>
                                    </div>
                                    <p><%= (e.getDescription().length() > 100) ? e.getDescription().substring(0, 100) + "..." : e.getDescription() %></p>
                                    <a href="event-details.jsp?id=<%= e.getEventID() %>" class="btn-event">View Details</a>
                                </div>
                                <div class="event-image-center"><img src="<%= request.getContextPath() %>/getImage?name=<%= img %>" onerror="this.src='assets/images/empty_image.png';"></div>
                                <div class="event-info-right">
                                    <div class="info-row"><i class="fa fa-clock-o"></i><div><strong><%= eDate.format(DateTimeFormatter.ofPattern("MMM dd, yyyy")) %></strong><span><%= e.getStartTime() %> - <%= e.getEndTime() %></span></div></div>
                                    <div class="info-row"><i class="fa fa-map-marker"></i><div><strong><%= e.getEventVenue() %></strong></div></div>
                                    <div class="info-row"><i class="fa fa-users"></i><div><%= regDao.getConfirmedCount(e.getEventID()) %> / <%= e.getMaxCapacity() %> Attending</div></div>
                                </div>
                            </div>
                        </div>
                        <% } } %>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </div></div></div>

    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
    <script src="assets/js/owl-carousel.js"></script>
    <script src="assets/js/isotope.js"></script>
    <script src="assets/js/slick.js"></script>
    <script src="assets/js/custom.js"></script>
    
    <script>
        function filterEvents() {
            const q = document.getElementById('titleSearch').value.toLowerCase();
            const cms = Array.from(document.querySelectorAll('.campus-filter:checked')).map(c => c.value);
            const tp = document.getElementById('typeFilter').value;

            // Filter cards in both tabs
            const panes = ['upcoming', 'past'];
            panes.forEach(paneId => {
                const pane = document.getElementById(paneId);
                const cards = pane.querySelectorAll('.event-card');
                let visibleCount = 0;

                cards.forEach(card => {
                    let show = (!q || card.dataset.title.includes(q)) &&
                               (!cms.length || cms.includes(card.dataset.campus)) &&
                               (tp === 'all' || card.dataset.type === tp);
                    
                    card.style.display = show ? "block" : "none";
                    if(show) visibleCount++;
                });

                // Show/Hide the "Not Found" message for THIS specific tab
                const emptyMsg = document.getElementById('empty-' + paneId);
                emptyMsg.style.display = (visibleCount === 0) ? "block" : "none";
            });
        }

        // Run filter once on load to handle initial empty states
        window.onload = filterEvents;

        document.querySelectorAll('.campus-filter').forEach(i => i.addEventListener('change', filterEvents));

        function resetFilters() { 
            document.getElementById('filterForm').reset(); 
            filterEvents(); 
        }

        function sortEvents() {
            const sb = document.getElementById('sortEvents').value;
            const active = document.querySelector('.tab-pane.active .event-container');
            const cards = Array.from(active.querySelectorAll('.event-card'));
            cards.sort((a, b) => {
                let vA = sb.includes('date') ? new Date(a.dataset.date) : a.dataset.title;
                let vB = sb.includes('date') ? new Date(b.dataset.date) : b.dataset.title;
                return sb.endsWith('asc') ? (vA > vB ? 1 : -1) : (vA < vB ? 1 : -1);
            }).forEach(c => active.appendChild(c));
        }
        
        $('a[data-toggle="pill"]').on('shown.bs.tab', filterEvents);
    </script>
</body>
</html>