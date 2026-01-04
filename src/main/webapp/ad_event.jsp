<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User, com.event.model.Event, com.event.dao.EventDAO, java.util.List"%>
<%
    // 1. Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Fetch Events from Database
    EventDAO dao = new EventDAO();
    List<Event> events = dao.getAllEvents();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Digitific | Manage Events</title>
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
</head>
<body>

    <header class="header-area header-sticky">
        <div class="container">
            <nav class="main-nav">
                <a href="admin_dashboard.jsp" class="logo"><em>Digitific</em></a>
                <ul class="nav">
                    <li><a href="admin_dashboard.jsp">Dashboard</a></li>
                    <li><a href="ad_event.jsp" class="active">Shows & Events</a></li>
                    <li><a href="users.jsp">Users</a></li>
                    <li><a href="LogoutServlet">Logout</a></li>
                </ul>        
            </nav>
        </div>
    </header>

    <div class="page-heading-shows-events">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>Our Shows & Events</h2>
                    <span>Check out upcoming and past shows & events.</span>
                </div>
            </div>
        </div>
    </div>

    <div class="shows-events-tabs">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="row" id="tabs">
                        <div class="col-lg-12">
                            <div class="heading-tabs">
                                <div class="row align-items-center">
                                    <div class="col-lg-12 d-flex justify-content-between align-items-center">
                                        <ul>
                                            <li><a href='#tabs-1'>Upcoming</a></li>
                                            <li><a href='#tabs-2'>Past</a></li>
                                        </ul>
                                        <div class="main-dark-button"><a href="add_event_form.jsp">Add Event</a></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-lg-12">
                            <section class='tabs-content'>
                                <article id='tabs-1'>
                                    <div class="row">
                                        <div class="col-lg-12">
                                            <div class="heading"><h2>Upcoming</h2></div>
                                        </div>

                                        <div class="col-lg-3">
                                            <div class="sidebar">
                                                <div class="row">
                                                    <div class="col-lg-12">
                                                        <div class="heading-sidebar"><h4>Filter Events</h4></div>
                                                    </div>
                                                    <div class="col-lg-12">
                                                        <div class="filter-section">
                                                            <h6><br>Branch Campus</h6>
                                                            <ul>
                                                                <li><a href="#">Puncak Alam</a></li>
                                                                <li><a href="#">Shah Alam</a></li>
                                                                <li><a href="#">Jasin</a></li>
                                                                <li><a href="#">Merbok</a></li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                    <div class="col-lg-12">
                                                        <div class="filter-section">
                                                            <h6>Category</h6>
                                                            <ul>
                                                                <li><a href="#">Club Activity</a></li>
                                                                <li><a href="#">Workshop</a></li>
                                                            </ul>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="col-lg-9">
                                            <div class="row">
                                                <% if (events == null || events.isEmpty()) { %>
                                                    <div class="col-lg-12">
                                                        <p>No events found. Click "Add Event" to create one.</p>
                                                    </div>
                                                <% } else { 
                                                    for(Event e : events) { %>
                                                    <div class="col-lg-12">
                                                        <div class="event-item">
                                                            <div class="row">
                                                                <div class="col-lg-4">
                                                                    <div class="left-content">
                                                                        <h4><%= e.getEventTitle() %></h4>
                                                                        <p><%= e.getDescription() %></p>
                                                                        <div class="main-dark-button"> 
                                                                            <a href="edit_event.jsp?id=<%= e.getEventID() %>">Edit Event</a>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4">
                                                                    <div class="thumb">
                                                                        <img src="<%= (e.getImageURL() != null) ? e.getImageURL() : "assets/images/event-page-01.jpg" %>" alt="">
                                                                    </div>
                                                                </div>
                                                                <div class="col-lg-4">
                                                                    <div class="right-content">
                                                                        <ul>
                                                                            <li><i class="fa fa-clock-o"></i>
                                                                                <h6><%= e.getEventDate() %><br><%= e.getStartTime() %></h6>
                                                                            </li>
                                                                            <li><i class="fa fa-map-marker"></i>
                                                                                <span><%= e.getEventVenue() %></span>
                                                                            </li>
                                                                            <li><i class="fa fa-users"></i>
                                                                                <span>Status: <%= e.getStatus() %></span>
                                                                            </li>
                                                                        </ul>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                <%  } 
                                                   } %>
                                            </div>
                                        </div>
                                    </div>
                                </article>

                                <article id='tabs-2'>
                                   <div class="row">
                                       <div class="col-lg-12">
                                           <div class="heading"><h2>Past Events</h2></div>
                                           <p>Archive of completed events will appear here.</p>
                                       </div>
                                   </div>
                                </article>
                            </section>
                        </div>
                    </div>
                </div>
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


    <script src="assets/js/jquery-2.1.0.min.js"></script>
    <script src="assets/js/custom.js"></script>
</body>
</html>