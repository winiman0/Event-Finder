<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.time.LocalDate, com.event.model.Event, com.event.dao.EventDAO, com.event.model.User, com.event.dao.RegistrationDAO"%>
<%
    // 1. Data Fetching & Validation
    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("ad_event.jsp");
        return;
    }
    
    EventDAO dao = new EventDAO();
    Event event = dao.getEventById(Integer.parseInt(idStr));
    
    if (event == null) {
        response.sendRedirect("ad_event.jsp");
        return;
    }
    
    // 2. User & Registration Logic
    User currentUser = (User) session.getAttribute("user");
    RegistrationDAO regDao = new RegistrationDAO();
    String userStatus = (currentUser != null) ? regDao.getUserRegistrationStatus(currentUser.getUserID(), event.getEventID()) : null;
    boolean alreadyRegistered = (userStatus != null);
    
    int confirmedCount = regDao.getConfirmedCount(event.getEventID());
    boolean isFull = confirmedCount >= event.getMaxCapacity();
    
    // 3. Status & Display Logic
    LocalDate today = LocalDate.now();
    boolean isPast = event.getEventDate().toLocalDate().isBefore(today);
    boolean isCancelled = "Cancelled".equalsIgnoreCase(event.getStatus());
    
    String imageName = (event.getImageURL() == null || event.getImageURL().isEmpty()) ? "empty_image.png" : event.getImageURL();
    String imgPath = request.getContextPath() + "/getImage?name=" + imageName;
    
    request.setAttribute("activePage", "events");
%>
<%@ include file="header.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title><%= event.getEventTitle() %></title>
    
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,200,300,400,500,600,700,800,900&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">

    <style>
        /* FIX: No more staircase effect */
        .right-content ul {
            list-style: none !important;
            padding: 0 !important;
            margin: 20px 0 !important;
        }
        .right-content ul li {
            display: flex !important;
            align-items: center;
            margin-bottom: 10px !important;
            font-size: 15px; /* Restored size */
            color: #333;
        }
        .right-content ul li i {
            width: 25px;
            margin-right: 10px;
            color: #777;
            text-align: center;
        }

        /* FIX: Badges aligned horizontally like Career Day image */
        .badge-container { 
            display: flex !important; 
            flex-direction: row !important;
            align-items: center; 
            gap: 10px; 
            flex-wrap: wrap; 
            margin-top: 10px !important;
            margin-bottom: 15px !important;
        }

        .header-details .badge { 
            padding: 8px 16px !important; 
            font-size: 12px; 
            border-radius: 25px;
            text-transform: capitalize;
            font-weight: 600;
        }

        /* Centering and Scaling */
        .left-image { 
            display: flex !important; 
            justify-content: center; 
            align-items: center; 
            background-color: #fff; 
            border-radius: 20px; 
            overflow: hidden; 
            border: 1px solid #eee;
            box-shadow: 0px 5px 15px rgba(0,0,0,0.05);
        }
        .left-image img { width: 100%; height: auto; object-fit: cover; }

        .header-details h4 { 
            font-size: 28px; 
            font-weight: 700; 
            margin-bottom: 5px !important;
        }

        /* Admin/Action boxes styling */
        .admin-actions, .guest-notice, .archived-notice { 
            margin-top: 20px !important; 
            padding: 20px;
            border-radius: 15px;
            border: 1px solid #eee;
        }
        
        .btn-cancel-spot {
            display: inline-block;
            background-color: #fff !important;
            color: #dc3545 !important; /* Red text */
            border: 1px solid #dc3545 !important; /* Red border */
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .btn-cancel-spot:hover {
            background-color: #dc3545 !important; /* Turns red on hover */
            color: #fff !important; /* Turns text white on hover */
            text-decoration: none;
        }

        /* Status Labels */
        .status-badge-attended { color: #28a745; font-weight: 700; }
        .status-badge-absent { color: #dc3545; font-weight: 700; }
    </style>
</head>

<body>
    <div id="js-preloader" class="js-preloader">
        <div class="preloader-inner"><span class="dot"></span><div class="dots"><span></span><span></span><span></span></div></div>
    </div>

    <div class="page-heading-shows-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2><%= isCancelled ? "Event Cancelled" : (isPast ? "Event Archive" : "Join Now!") %></h2>
                    <span><%= isCancelled ? "This event will no longer take place." : (isPast ? "This event has already concluded." : "Empty seats running out!") %></span>
                </div>
            </div>
        </div>
    </div>

    <div class="ticket-details-page">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <% if (isCancelled) { %>
                        <div class="alert alert-danger shadow-sm">
                            <h4 class="alert-heading"><i class="fa fa-exclamation-triangle"></i> Event Cancelled</h4>
                            <p class="mb-0">This event has been officially cancelled by the administration.</p>
                        </div>
                    <% } %>
                    
                    <% String msg = request.getParameter("msg");
                       if ("cancelled".equals(msg)) { %>
                        <div class="alert alert-warning"><strong>Cancelled!</strong> Your registration has been removed.</div>
                    <% } else if ("success".equals(msg)) { %>
                        <div class="alert alert-success"><strong>Success!</strong> You are confirmed for this event.</div>
                    <% } else if ("joined".equals(msg)) { %>
                        <div class="alert alert-info"><strong>Waitlisted!</strong> The event is full, but you are in line.</div>
                    <% } else if ("statusUpdated".equals(msg)) { %>
                        <div class="alert alert-success alert-dismissible fade show">
                            <i class="fa fa-check-circle"></i> <strong>Updated!</strong> Event status changed successfully.
                            <button type="button" class="close" data-dismiss="alert">&times;</button>
                        </div>
                    <% } %>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-8">
                    <div class="left-image">
                        <img src="<%= imgPath %>" onerror="this.src='assets/images/empty_image.png';" alt="<%= event.getEventTitle() %>">
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="right-content">
                        <div class="header-details">
                            <h4><%= event.getEventTitle() %></h4>
                            
                            <div class="badge-container">
                                <span style="font-size: 15px; color: #666; font-weight: 500;">
                                    <% if (isFull) { %>
                                        <b style="color: #fb3f3f;"><i class="fa fa-exclamation-circle"></i> FULL</b>
                                    <% } else { %>
                                        <i class="fa fa-users"></i> <%= event.getMaxCapacity() - confirmedCount %> Slots Available
                                    <% } %>
                                </span>

                                <% if (event.getEventType() != null) { %>
                                    <span class="badge" style="background-color: #3B0270; color: white;"><%= event.getEventType() %></span>
                                <% } %>

                                <% if (event.getMeritPoints() > 0) { %>
                                    <span class="badge" style="background-color: #28a745; color: white;"><i class="fa fa-star"></i> <%= event.getMeritPoints() %> Merit</span>
                                <% } %>

                                <% if (isPast) { %>
                                    <span class="badge" style="background-color: #6c757d; color: white;"><i class="fa fa-check-circle"></i> Completed</span>
                                <% } %>
                            </div>
                        </div>

                        <ul>
                            <li><i class="fa fa-calendar"></i> <strong>Date:</strong> <%= event.getEventDate() %></li>
                            <li><i class="fa fa-clock-o"></i> <strong>Time:</strong> <%= event.getStartTime() %> - <%= event.getEndTime() %></li>
                            <li><i class="fa fa-map-marker"></i> <strong>Venue:</strong> <%= event.getEventVenue() %></li>
                            <% if (event.getCampusName() != null) { %>
                                <li><i class="fa fa-university"></i> <strong>Campus:</strong> <%= event.getCampusName() %></li>
                            <% } %>
                            <% if (event.getOrganizerName() != null) { %>
                                <li><i class="fa fa-user"></i> <strong>Organizer:</strong> <%= event.getOrganizerName() %></li>
                            <% } %>
                        </ul>

                        <div class="quantity-content mt-4">
                            <h6>Description</h6>
                            <p><%= event.getDescription() %></p>
                        </div>

                        <div class="total">
    <% if (isCancelled) { %>
        <%-- 1. IF CANCELLED: Restore original "Locked" design and buttons --%>
        <div class="p-3 text-center" style="background: #f8f9fa; border-radius: 10px; border: 1px dashed #ccc;">
            <h6 class="text-muted"><i class="fa fa-lock"></i> Registration Unavailable</h6>
            <p class="small">This event is no longer active.</p>
            
            <% if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) { %>
                <div style="display: flex; gap: 10px; margin-bottom: 10px;">
                    <a href="manage_event.jsp?id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #4e73df; color: white; border-radius: 8px;">Edit</a>
                    <a href="EventServlet?action=delete&id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #e74a3b; color: white; border-radius: 8px;" onclick="return confirm('Delete this event?')">Delete</a>
                </div>
                <a href="ExportParticipantsServlet?eventId=<%= event.getEventID() %>" class="btn btn-outline-secondary btn-block">
                    <i class="fa fa-file-excel-o"></i> View Final Participant List
                </a>
            <% } %>
        </div>

    <% } else if (isPast) { %>
        <%-- 2. ARCHIVED VIEW: Restore original grey-themed notice and admin buttons --%>
        <div class="archived-notice" style="background: #e9ecef; padding: 20px; border-radius: 10px; border-left: 5px solid #6c757d;">
            <h6>Event Concluded</h6>
            <p style="margin-bottom: 10px;">This event took place on <%= event.getEventDate() %>. Registration are closed.</p>

            <% if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) { %>
                <div style="display: flex; gap: 10px; margin-bottom: 10px;">
                    <a href="manage_event.jsp?id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #4e73df; color: white; border-radius: 8px;">Edit</a>
                    <a href="EventServlet?action=delete&id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #e74a3b; color: white; border-radius: 8px;" onclick="return confirm('Delete this event?')">Delete</a>
                </div>
                <a href="ExportParticipantsServlet?eventId=<%= event.getEventID() %>" class="btn btn-outline-secondary btn-block">
                    <i class="fa fa-file-excel-o"></i> View Final Participant List
                </a>
            <% } else if (alreadyRegistered) { %>
                <% if ("Attended".equalsIgnoreCase(userStatus)) { %>
                    <div class="alert alert-success" style="font-size: 14px; border-left: 5px solid #28a745;">
                        <i class="fa fa-certificate"></i> <strong>Attendance Verified!</strong><br>
                        You earned <strong><%= event.getMeritPoints() %></strong> Merit Points.
                    </div>
                <% } else { %>
                    <div class="alert alert-secondary" style="font-size: 14px; border-left: 5px solid #6c757d;">
                        <i class="fa fa-info-circle"></i> You were registered, but attendance was not recorded.
                    </div>
                <% } %>
            <% } %>
        </div>

    <% } else { %>
        <%-- 3. ACTIVE VIEW --%>
        
        <%-- Admin Control Panel Design --%>
        <% if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) { %>
            <div class="admin-actions" style="background: rgba(186, 192, 123,0.7); border: 1px solid transparent; padding: 25px; border-radius: 15px; color: #fff;">
                <h5 style="color: #444722; letter-spacing: 1px; margin-bottom: 20px;">Admin Control Panel</h5><hr>

                <form action="EventServlet" method="POST" style="margin-bottom: 20px;">
                    <input type="hidden" name="action" value="updateStatus">
                    <input type="hidden" name="eventId" value="<%= event.getEventID() %>">
                    <label style="font-size: 15px; color: #444722; display: block; margin-bottom: 8px;">Update Event Status :</label>
                    <select name="status" onchange="this.form.submit()" 
                            style="width: 100%; background: white; border: 1px solid #40407a; color: #444722; padding: 10px; border-radius: 8px; outline: none;">
                        <option value="Upcoming" <%= "Upcoming".equalsIgnoreCase(event.getStatus()) ? "selected" : "" %>>Upcoming</option>
                        <option value="Ongoing" <%= "Ongoing".equalsIgnoreCase(event.getStatus()) ? "selected" : "" %>>Ongoing</option>
                        <option value="Completed" <%= "Completed".equalsIgnoreCase(event.getStatus()) ? "selected" : "" %>>Completed</option>
                        <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(event.getStatus()) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </form>

                <p style="font-size: 15px; color: #444722; display: block; margin-bottom: 8px;">Manage Event :</p>
                <div style="display: flex; gap: 10px;">
                    <a href="manage_event.jsp?id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #4e73df; color: white; border-radius: 8px;">Edit</a>
                    <a href="EventServlet?action=delete&id=<%= event.getEventID() %>" class="btn btn-sm" style="flex: 1; background: #e74a3b; color: white; border-radius: 8px;" onclick="return confirm('Delete this event?')">Delete</a>
                </div>

                <hr style="border-top: 1px solid #30305a; margin: 20px 0;">

                <a href="ExportParticipantsServlet?eventId=<%= event.getEventID() %>" class="btn btn-outline-success btn-block" style="border-radius: 8px; font-size: 13px;">
                    <i class="fa fa-file-excel-o"></i> Export CSV
                </a>
            </div>

        <%-- Student Actions --%>
        <% } else if (currentUser != null) { %>
            <div class="main-dark-button" style="margin-top: 30px;">
                <% if (alreadyRegistered) { %>
                    <div class="user-status-notice" style="margin-bottom: 15px; padding: 15px; border-radius: 8px; background: #f8f9fa; 
                        border-left: 5px solid <%= "Attended".equalsIgnoreCase(userStatus) ? "#28a745" : "Confirmed".equalsIgnoreCase(userStatus) ? "#007bff" : "#ffc107" %>;">
                        
                        <small style="color: #666;">Your Current Status:</small> 
                        <strong style="display: block; color: <%= "Attended".equalsIgnoreCase(userStatus) ? "#28a745" : "#333" %>;">
                            <%= "Attended".equalsIgnoreCase(userStatus) ? "<i class='fa fa-check-circle'></i> ATTENDED (+" + event.getMeritPoints() + " Points)" : userStatus %>
                        </strong>

                        <% if ("Waiting".equalsIgnoreCase(userStatus)) { %>
                            <p style="font-size: 12px; margin: 0; color: #856404;">You are in the queue. You'll be moved to confirmed if a spot opens up.</p>
                        <% } else if ("Confirmed".equalsIgnoreCase(userStatus)) { %>
                            <p style="font-size: 12px; margin: 0; color: #004085;">Your seat is reserved. See you there!</p>
                        <% } %>
                    </div>

                    <% if (!"Attended".equalsIgnoreCase(userStatus)) { %>
                        <a href="EventRegistrationServlet?action=cancel&eventId=<%= event.getEventID() %>" 
                           style="background-color: #fb3f3f;" 
                           onclick="return confirm('Remove yourself from this event?')">
                           <%= "Waiting".equalsIgnoreCase(userStatus) ? "Leave Waitlist" : "Cancel My Spot" %>
                        </a>
                    <% } %>

                <% } else if (isFull) { %>
                    <a href="EventRegistrationServlet?eventId=<%= event.getEventID() %>" style="background: #666;">Join Waitlist</a>
                <% } else { %>
                    <a href="EventRegistrationServlet?eventId=<%= event.getEventID() %>">Register for Event</a>
                <% } %>
            </div>

        <%--  Guest Notice --%>
        <% } else { %>
             <div class="guest-notice" style="background: #fff3cd; padding: 20px; border-radius: 10px; border: 1px solid #ffeeba; margin-top: 30px;">
                <p style="color: #856404; font-weight: 500;"><i class="fa fa-lock"></i> Want to join this event?</p>
                <div class="main-dark-button" style="margin-top: 10px;">
                    <a href="login.jsp?redirect=event-details.jsp?id=<%= event.getEventID() %>">Login to Register</a>
                </div>
             </div>
        <% } %>
    <% } %>
</div></div></div></div>
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
</body>
</html>