<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*, com.event.dao.*, com.event.model.Event"%>
<%@page import="com.event.model.Registration"%>
<%
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int currentYear = 2026; 
    String eventIdParam = request.getParameter("eventId");
    EventDAO eventDao = new EventDAO();
    RegistrationDAO regDao = new RegistrationDAO();
    
    // Logic for Sidebar: Default to events from this year
    List<Event> recentEvents = eventDao.getAllEvents(); 
    Set<String> campuses = new HashSet<>();
    for(Event e : recentEvents) { if(e.getCampusName() != null) campuses.add(e.getCampusName()); }
    
    Event selectedEvent = null;
    List<Registration> participants = new ArrayList<>();
    if (eventIdParam != null) {
        int eventId = Integer.parseInt(eventIdParam);
        selectedEvent = eventDao.getEventById(eventId);
        participants = regDao.getRegistrationsByEvent(eventId); 
    }
%>
<%@ include file="header.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Manage Participants</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap4.min.css">
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,200,300,400,500,600,700,800,900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/font-awesome.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">

    <style>
       
    :root {
        --bg-color: #f8fafb;
        --sidebar-bg: #ffffff;
        --card-bg: #ffffff;
        --text-main: #1f2417; 
        --text-muted: #7f8c8d;
        --accent-soft: #f0f3f7; 
        --border-color: #84A98C;
    }

    body { 
        background-color: var(--bg-color); 
        font-family: 'Poppins', sans-serif; 
        color: var(--text-main); 
    }

    h1, h2, h3, h4, h5, h6 {
        color: var(--text-main) !important;
        font-weight: 700;
    }

    .sidebar { 
        background: var(--sidebar-bg); 
        height: calc(100vh - 80px); 
        position: sticky; 
        top: 80px; 
        border-right: 1px solid var(--border-color); 
        padding: 30px 20px;
    }

    /* Professional Button */
    .btn-view-event {
        background-color: #ffffff;
        color: #1f2417;
        border: 1px solid #dfe6e9;
        font-weight: 500;
        border-radius: 10px;
        padding: 10px 20px;
        transition: 0.2s;
    }
    .btn-view-event:hover {
        background-color: #f8fafb;
        border-color: #b2bec3;
    }

    /* Event Cards */
   
    .event-card {
        background: #ffffff; 
        padding: 15px;
        margin-bottom: 12px;
        display: block;
        text-decoration: none !important;
        border-radius: 12px;
        transition: all 0.3s ease;
        border: 1px solid rgba(132, 169, 140, 0.5); 
    }

    /* THE HOVER STATE */
    .event-card:hover {
        background: var(--accent-soft);
        border-color: #cbd5e0; /* Slightly darker on hover */
        transform: translateY(-2px); /* Subtle lift effect */
    }

    /* THE ACTIVE (SELECTED) STATE */
    .event-card.active {
        background: #ffffff;
        border: 1px solid #a29bfe !important; 
        box-shadow: 0 4px 12px rgba(162, 155, 254, 0.15);
    }
    /* Clean Badges */
    .badge-soft { 
        padding: 6px 12px; 
        border-radius: 6px; 
        font-weight: 600; 
        font-size: 11px; 
        display: inline-block;
    }
    .badge-campus { background-color: #e0f2f1; color: #00796b; } 
    .badge-status-confirmed { background-color: #fff3e0; color: #e65100; } /* Soft Orange */
    .badge-status-attended { background-color: #e8f5e9; color: #2e7d32; } /* Soft Green */

    .main-card { 
        background: var(--card-bg); 
        border: 1px solid var(--border-color); 
        box-shadow: 0 2px 20px rgba(0,0,0,0.02); 
        border-radius: 16px;
    }

    /* Remove the dark table look */
    .table { color: var(--text-main); }
    .table thead th { 
        background: #fafafa;
        color: var(--text-muted);
        text-transform: uppercase;
        font-size: 11px;
        letter-spacing: 1px;
        border: none;
    }
    .table td { border-top: 1px solid #f1f4f8; padding: 20px 15px; }
    


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
        

    <!-- Page Heading -->
    <div class="page-heading-shows-events">
        <div class="container">
            <p style="color:white; font-size: 50px; font-weight: 600; margin-bottom: 20px;">Manage Participants</p>
            <span>Update the attendance of participants</span>
        </div>
    </div>

<div class="container-fluid">
    <div class="row">
        <div class="col-md-3 sidebar">
            <h5 class="mb-4" style="font-weight: 700; color: #2d3436;">Filters</h5>
            <div class="filter-group">
                <label class="small text-muted mb-2">Search Events</label>
                <input type="text" id="eventSearch" class="form-control" placeholder="e.g. Workshop...">
            </div>

            <div class="row g-2 mt-3"> <div class="col-6">
                    <label class="small text-muted mb-1">Campus</label>
                    <select class="form-select" id="campusFilter">
                        <option value="">All</option>
                        <% for(String c : campuses) { %>
                            <option value="<%= c %>"><%= c %></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-6">
                    <label class="small text-muted mb-1">Year</label>
                    <select class="form-select" id="yearFilter">
                        <option value="">All</option>
                        <% 
                            
                            int currentYr = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                            for(int i = currentYr; i >= 1945; i--) { 
                        %>
                            <option value="<%= i %>" <%= (i == 2026 ? "selected" : "") %>><%= i %></option>
                        <% } %>
                    </select>
                </div>
            </div>

            <hr class="my-4" style="opacity: 0.1;">

            <div class="event-list-container" id="eventList">
                <%-- The sidebar loop --%>
                <% 
                    Calendar cal = Calendar.getInstance();
                    for(Event e : recentEvents) { 
                        if(e.getEventDate() != null) {
                            cal.setTime(e.getEventDate());
                            int eYear = cal.get(Calendar.YEAR);
                %>
                <a href="?eventId=<%= e.getEventID() %>" 
                    class="event-card <%= (selectedEvent != null && e.getEventID() == selectedEvent.getEventID()) ? "active" : "" %>"
                    data-campus="<%= e.getCampusName() %>"
                    data-year="<%= eYear %>">

                     <div class="d-flex justify-content-between align-items-center mb-2">
                         <small class="text-muted" style="font-size: 11px;"><%= e.getEventDate() %></small>
                         <span class="badge-soft badge-campus"><%= e.getCampusName() %></span>
                     </div>

                     <h6 class="mb-0" style="font-size: 14px; font-weight: 600;"><%= e.getEventTitle() %></h6>
                 </a>
                <% } } %>
            </div>
        </div>

        <div class="col-md-9 p-5">
            <% if (selectedEvent == null) { %>
                <div class="d-flex flex-column justify-content-center align-items-center text-center" style="min-height: 70vh;">
                    <div class="mb-4"><i class="fa fa-calendar-check-o" style="font-size: 100px; color: #3b3b5e; opacity: 0.5;"></i></div>
                    <h2 class="fw-bold" style="color: #1F2417">Event Attendance Manager</h2>
                    <p class="text-muted" style="max-width: 400px;">Please select an event from the sidebar.</p>
                </div>
            <% } else { %>
                <div class="d-flex justify-content-between align-items-end mb-4">
                    <div>
                        <h1 class="fw-bold" style="color: #1F2417"><%= selectedEvent.getEventTitle() %></h1>
                        <span class="badge badge-pastel-blue px-3 py-2">
                            <i class="fa fa-map-marker"></i> <%= selectedEvent.getEventVenue() %>
                        </span>
                    </div>
                    <a href="event-details.jsp?id=<%= selectedEvent.getEventID() %>" class="btn btn-view-event">
                        <i class="fa fa-eye"></i> View Event Page
                    </a>
                </div>

                <div class="row mb-4">
                    <div class="col-md-4">
                        <div class="card text-center p-3 shadow-sm" style="border-radius: 12px; border-left: 5px solid #3498db;">
                            <small class="text-muted text-uppercase fw-bold">Total Registered</small>
                            <h2 class="mb-0" id="stat-total"><%= participants.size() %></h2>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card text-center p-3 shadow-sm" style="border-radius: 12px; border-left: 5px solid #2ecc71;">
                            <small class="text-muted text-uppercase fw-bold">Attended</small>
                            <h2 class="mb-0 text-success" id="stat-attended">0</h2>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card text-center p-3 shadow-sm" style="border-radius: 12px; border-left: 5px solid #e74c3c;">
                            <small class="text-muted text-uppercase fw-bold">Absentees</small>
                            <h2 class="mb-0 text-danger" id="stat-absent">0</h2>
                        </div>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div class="btn-group shadow-sm">
                        <button onclick="markAllAttended()" class="btn btn-sm btn-white text-primary border">
                            <i class="fa fa-check-square-o"></i> Mark All Attended
                        </button>
                        <button onclick="exportParticipantsToCSV()" class="btn btn-sm btn-success">
                            <i class="fa fa-file-excel-o"></i> Export CSV
                        </button>
                    </div>
                    <span class="text-muted small"><i class="fa fa-info-circle"></i> Changes saved automatically</span>
                </div>

                <div class="card main-card">
                    <div class="card-body p-4">
                        <div class="table-responsive">
                            <table class="table" id="participantTableParent">
                                <thead>
                                    <tr>
                                        <th>Student</th>
                                        <th>Status</th>
                                        <th class="text-center">Attendance</th>
                                    </tr>
                                </thead>
                                <tbody id="participantTable">
                                    <% for(com.event.model.Registration r : participants) { 
                                        boolean isAttended = "Attended".equalsIgnoreCase(r.getStatus());
                                        String statusLabel = isAttended ? "Attended" : "Confirmed";
                                        String statusClass = isAttended ? "badge-status-attended" : "badge-status-confirmed";
                                    %>
                                        <tr>
                                            <td>
                                                <div style="font-weight: 600; color: #1F2417;"><%= r.getFullName() %></div>
                                                <small class="text-muted"><%= r.getUserID() %></small>
                                            </td>
                                            <td>
                                                <span class="status-label badge-soft <%= statusClass %>"><%= statusLabel %></span>
                                            </td>
                                            <td class="text-center">
                                                <input type="checkbox" class="toggle-attended" 
                                                       style="width: 18px; height: 18px; cursor:pointer;"
                                                       <%= isAttended ? "checked" : "" %>
                                                       data-uid="<%= r.getUserID() %>" 
                                                       data-eid="<%= selectedEvent.getEventID() %>">
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
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
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap4.min.js"></script>

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
$(document).ready(function() {
    // 1. Initialize DataTable
    const table = $('#participantTableParent').DataTable({
        "paging": true,
        "pageLength": 10,
        "searching": true,
        "language": { "search": "Filter students:" }
    });

    // 2. Initial Stats Load
    updateStats();

    // 3. Attendance Toggle (Event Delegation)
    $(document).on("change", ".toggle-attended", function() {
        const checkbox = $(this);
        const userId = checkbox.data("uid");
        const eventId = checkbox.data("eid");
        const isChecked = checkbox.is(":checked");
        const newStatus = isChecked ? "Attended" : "Confirmed";
        const statusLabel = checkbox.closest("tr").find(".status-label");

        $.post("UpdateAttendanceServlet", {
            userId: userId,
            eventId: eventId,
            status: newStatus
        }, function(response) {
            statusLabel.text(newStatus);
            if(isChecked) {
                statusLabel.removeClass("badge-status-confirmed").addClass("badge-status-attended");
            } else {
                statusLabel.removeClass("badge-status-attended").addClass("badge-status-confirmed");
            }
            updateStats(); // Refresh the top cards
        }).fail(function() {
            alert("Error updating attendance.");
            checkbox.prop("checked", !isChecked);
        });
    });

    // 4. Sidebar Filter Logic
    $("#eventSearch, #campusFilter, #yearFilter").on("change keyup", function() {
        const search = $("#eventSearch").val().toLowerCase();
        const campus = $("#campusFilter").val();
        const year = $("#yearFilter").val();

        $(".event-card").each(function() {
            const card = $(this);
            const matchesSearch = card.text().toLowerCase().indexOf(search) > -1;
            const matchesCampus = campus === "" || card.data("campus") === campus;
            const matchesYear = year === "" || card.data("year").toString() === year;
            card.toggle(matchesSearch && matchesCampus && matchesYear);
        });
    });
});

// --- Outside ready() functions ---

function updateStats() {
    const table = $('#participantTableParent').DataTable();
    const total = table.rows().count();
    let attended = 0;

    table.rows().every(function() {
        if ($(this.node()).find('.toggle-attended').is(':checked')) {
            attended++;
        }
    });

    $("#stat-total").text(total);
    $("#stat-attended").text(attended);
    $("#stat-absent").text(total - attended);
}

function markAllAttended() {
    if (!confirm("Mark ALL participants as attended?")) return;
    const table = $('#participantTableParent').DataTable();
    
    table.rows().every(function() {
        const checkbox = $(this.node()).find('.toggle-attended');
        if (!checkbox.is(':checked')) {
            checkbox.prop('checked', true).trigger('change'); 
        }
    });
}

function exportParticipantsToCSV() {
    const table = $('#participantTableParent').DataTable();
    const eventTitle = "<%= (selectedEvent != null) ? selectedEvent.getEventTitle() : "Event" %>";
    const eventDate = "<%= (selectedEvent != null) ? selectedEvent.getEventDate() : "" %>";
    
    let csv = [eventTitle + " Attendance on " + eventDate, "", "Student Name,Student ID,Status"];

    table.rows().every(function() {
        const row = $(this.node());
        const name = row.find("td:eq(0) div").text().trim().replace(/,/g, "");
        const id = row.find("td:eq(0) small").text().trim();
        const status = row.find(".toggle-attended").is(":checked") ? "Attended" : "Absent";
        csv.push(name + "," + id + "," + status);
    });

    const blob = new Blob([csv.join("\n")], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.setAttribute("download", eventTitle.replace(/\s+/g, '_') + "_Attendance.csv");
    link.click();
}
</script>
</body>
</html>