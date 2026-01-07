<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.Event, com.event.dao.EventDAO, com.event.model.User, com.event.dao.RegistrationDAO"%>
<%
    String idStr = request.getParameter("id");
    if (idStr == null) {
        response.sendRedirect("shows-events.jsp");
        return;
    }
    
    EventDAO dao = new EventDAO();
    Event event = dao.getEventById(Integer.parseInt(idStr));
    
    if (event == null) {
        response.sendRedirect("shows-events.jsp");
        return;
    }
    
    User currentUser = (User) session.getAttribute("user");
    RegistrationDAO regDao = new RegistrationDAO();
    
    int confirmedCount = regDao.getConfirmedCount(event.getEventID());
    boolean isFull = confirmedCount >= event.getMaxCapacity();
    boolean alreadyRegistered = (currentUser != null) ? regDao.isStudentRegistered(currentUser.getUserID(), event.getEventID()) : false;
    request.setAttribute("activePage", "events");
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

    <title><%= event.getEventTitle() %></title>
    
    <!-- Additional CSS Files -->
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">

    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">

    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <!--

Tooplate 2125 ArtXibition

https://www.tooplate.com/view/2125-artxibition

-->
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
    <div class="page-heading-shows-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>Join Now!</h2>
                    <span>Empty seats running out!</span>
                </div>
            </div>
        </div>
    </div>
    
    <div class="ticket-details-page">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <% 
                        String msg = request.getParameter("msg");
                        if ("cancelled".equals(msg)) { 
                    %>
                        <div class="alert alert-warning alert-dismissible fade show" role="alert">
                            <strong>Cancelled!</strong> Your registration has been removed.
                        </div>
                    <% } else if ("success".equals(msg)) { %>
                        <div class="alert alert-success alert-dismissible fade show" role="alert">
                            <strong>Success!</strong> You are confirmed for this event.
                        </div>
                    <% } else if ("joined".equals(msg)) { %>
                        <div class="alert alert-info alert-dismissible fade show" role="alert">
                            <strong>Waitlisted!</strong> The event is full, but you are in line.
                        </div>
                    <% } %>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-8">
                    <div class="left-image">
                        <img src="assets/images/events/<%= event.getImageURL() %>" alt="<%= event.getEventTitle() %>">
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="right-content">
                        <h4><%= event.getEventTitle() %></h4>
                            <span>
                                <% if (isFull) { %>
                                    <b style="color: red;">EVENT FULL (Waitlist Open)</b>
                                <% } else { %>
                                    <%= event.getMaxCapacity() - confirmedCount %> Slots Available
                                <% } %>
                            </span>
                        <ul>
                            <li><i class="fa fa-clock-o"></i> <%= event.getEventDate() %> | <%= event.getStartTime() %> - <%= event.getEndTime() %></li>
                            <li><i class="fa fa-map-marker"></i> <%= event.getEventVenue() %></li>
                            <li><i class="fa fa-star"></i> Merit Points: <%= event.getMeritPoints() %></li>
                        </ul>
                        
                        <div class="quantity-content">
                            <div class="left-content">
                                <h6>Description</h6>
                                <p><%= event.getDescription() %></p>
                            </div>
                        </div>

                            <div class="total">
                                <%-- 1. Check if user is logged in AND is an admin --%>
                                <% if (currentUser != null && "admin".equalsIgnoreCase(currentUser.getRole())) { %>
                                    <div class="admin-actions" style="background: #f4f4f4; padding: 15px; border-radius: 5px;">
                                        <a href="manage_event.jsp?id=<%= event.getEventID() %>" class="btn btn-sm btn-warning">Edit Event</a>
                                        <a href="EventServlet?action=delete&id=<%= event.getEventID() %>" class="btn btn-sm btn-danger" onclick="return confirm('Delete this event?')">Delete</a>
                                        <hr>
                                        <a href="ExportParticipantsServlet?eventId=<%= event.getEventID() %>" class="btn btn-sm btn-success">Export Participants (CSV)</a>
                                    </div>

                                <%-- 2. If user is logged in but NOT an admin (Student) --%>
                                <% } else if (currentUser != null) { %>
                                    <% if (alreadyRegistered) { %>
                                        <div class="main-dark-button">
                                            <a href="EventRegistrationServlet?action=cancel&eventId=<%= event.getEventID() %>" 
                                               style="background-color: #fb3f3f;" 
                                               onclick="return confirm('Are you sure you want to cancel your spot?')">
                                               Cancel Registration
                                            </a>
                                        </div>
                                    <% } else if (isFull) { %>
                                        <div class="main-dark-button">
                                            <a href="EventRegistrationServlet?eventId=<%= event.getEventID() %>" style="background: #333;">Join Waitlist</a>
                                        </div>
                                    <% } else { %>
                                        <div class="main-dark-button">
                                            <a href="EventRegistrationServlet?eventId=<%= event.getEventID() %>">Register Now</a>
                                        </div>
                                    <% } %>

                                <%-- 3. If user is a Guest (not logged in) --%>
                                <% } else { %>
                                     <div class="guest-notice" style="background: #fff3cd; padding: 15px; border-radius: 10px; border: 1px solid #ffeeba; margin-bottom: 20px;">
                                        <p style="color: #856404; margin-bottom: 10px;">
                                            <i class="fa fa-info-circle"></i> Want to earn <strong><%= event.getMeritPoints() %> merit points</strong>? Log in to secure your spot!
                                        </p>
                                        <div class="main-dark-button">
                                            <a href="login.jsp?redirect=event-details.jsp?id=<%= event.getEventID() %>">Login to Register</a>
                                        </div>
                                     </div>
                                <% } %>
                            </div>
        </div>
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
    </body>
</html>