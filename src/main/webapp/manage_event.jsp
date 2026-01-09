<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.Event, com.event.dao.EventDAO, com.event.model.User, java.util.List"%>
<%
    // 1. Security Check
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    EventDAO dao = new EventDAO();
    
    // 2. Determine if we are Editing or Adding
    String idParam = request.getParameter("id");
    Event event = null;
    boolean isEdit = false;

    if (idParam != null && !idParam.isEmpty()) {
        event = dao.getEventById(Integer.parseInt(idParam));
        if (event != null) {
            isEdit = true;
        }
    }

    // 3. Set up the Image Path 
    String displayImagePath;
    if (isEdit && event.getImageURL() != null && !event.getImageURL().isEmpty()) {
        // FIX: Use the servlet for uploaded (external) images
        displayImagePath = "getImage?name=" + event.getImageURL();
    } else {
        // This stays the same because it's a static file inside your project
        displayImagePath = "assets/images/empty_image.png";
    }
    
    request.setAttribute("activePage", "events");
%>
<%@ include file="header.jsp" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Add/Edit Event</title>

    <link href="https://fonts.googleapis.com/css?family=Poppins:100,200,300,400,500,600,700,800,900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/font-awesome.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            color: #3B0270;
            background-color: #f9f7fc;
        }

        .page-heading-event {
            background: #e8e2f5;
            padding: 40px 0;
            text-align: center;
        }

        .page-heading-event h2 {
            font-weight: 700;
        }

        .page-heading-event span {
            color: #3B0270;
        }

        .event-form-container {
            margin: 40px auto;
            background-color: #fff;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0px 4px 12px rgba(0, 0, 0, 0.1);
        }

        .left-upload {
            background-color: #f2effa;
            border-radius: 10px;
            padding: 20px;
            text-align: center;
        }

        .left-upload img {
            max-width: 100%;
            border-radius: 10px;
            margin-bottom: 15px;
        }

        .form-control {
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        .form-control:focus {
            border-color: #6c63ff;
            box-shadow: none;
        }

        .submit-btn {
            background-color: #6c63ff;
            color: #fff;
            border: none;
            padding: 10px 25px;
            border-radius: 5px;
            font-weight: 600;
            transition: 0.3s;
        }

        .submit-btn:hover {
            background-color: #4b42c1;
            color: #fff;
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
        

    <!-- Page Heading -->
    <div class="page-heading-event">
        <div class="container">
            <h2>Add/Edit Event</h2>
            <span>Fill in the details below</span>
        </div>
    </div>

    <div class="container event-form-container">
    <form action="EventServlet" method="post" enctype="multipart/form-data">
        
        <input type="hidden" name="eventId" value="<%= isEdit ? event.getEventID() : "0" %>">
        <input type="hidden" name="action" value="<%= isEdit ? "update" : "add" %>">

        <div class="row">
            <div class="col-lg-4">
                <div class="left-upload">
                    <img src="${pageContext.request.contextPath}/<%= displayImagePath %>" 
                         alt="Event Image" id="preview" style="width:200px; height:auto;">

                    <div class="form-group">
                        <label for="eventImage">Upload Event Poster</label>
                        <input type="file" id="eventImage" name="eventImage" class="form-control" accept="image/*" onchange="previewImage(event)">

                        <input type="hidden" name="existingImage" value="<%= isEdit ? event.getImageURL() : "" %>">

                        <small class="text-muted">Keep empty to retain current image</small>
                    </div>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="form-group">
                    <label>Event Title</label>
                    <input type="text" name="title" class="form-control" required 
                           value="<%= isEdit ? event.getEventTitle() : "" %>">
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" class="form-control" rows="4" required><%= isEdit ? event.getDescription() : "" %></textarea>
                </div>

                <div class="row">
                    <div class="col-md-6 form-group">
                        <label>Date</label>
                        <input type="date" name="date" class="form-control" required 
                               value="<%= isEdit ? event.getEventDate() : "" %>">
                    </div>
                    <div class="col-md-6 form-group">
                        <label>Venue</label>
                        <input type="text" name="venue" class="form-control" required 
                               value="<%= isEdit ? event.getEventVenue() : "" %>">
                    </div>
                </div>

               <div class="row">
                    <div class="col-md-3 form-group">
                        <label>Start Time</label>
                        <input type="time" name="start_time" class="form-control" required 
                               value="<%= isEdit ? event.getStartTime() : "" %>">
                    </div>
                    <div class="col-md-3 form-group">
                        <label>End Time</label>
                        <input type="time" name="end_time" class="form-control" required 
                               value="<%= isEdit ? event.getEndTime() : "" %>">
                    </div>
                    <div class="col-md-3 form-group">
                        <label>Merit Points</label>
                        <input type="number" name="meritPoints" class="form-control" required 
                               value="<%= isEdit ? event.getMeritPoints() : "0" %>">
                    </div>
                    <div class="col-md-3 form-group">
                        <label>Max Capacity</label>
                        <input type="number" name="maxCapacity" class="form-control" required 
                               value="<%= isEdit ? event.getMaxCapacity() : "100" %>">
                    </div>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status" class="form-control">
                        <option value="Upcoming" <%= (isEdit && "Upcoming".equals(event.getStatus())) ? "selected" : "" %>>Upcoming</option>
                        <option value="Ongoing" <%= (isEdit && "Ongoing".equals(event.getStatus())) ? "selected" : "" %>>Ongoing</option>
                        <option value="Completed" <%= (isEdit && "Completed".equals(event.getStatus())) ? "selected" : "" %>>Completed</option>
                        <option value="Cancelled" <%= (isEdit && "Cancelled".equals(event.getStatus())) ? "selected" : "" %>>Cancelled</option>
                    </select>
                </div>
                <div class="row">
                    <div class="col-md-6 form-group">
                        <label>Campus</label>
                        <select name="campusID" class="form-control" required>
                            <option value="">-- Select Campus --</option>
                            <% 
                                for (String[] camp : dao.getAllCampusesList()) { 
                                    boolean isSelected = isEdit && camp[0].equals(event.getCampusID());
                            %>
                                <option value="<%= camp[0] %>" <%= isSelected ? "selected" : "" %>>
                                    <%= camp[1] %> </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-6 form-group">
                        <label>Organizer</label>
                        <select name="organizerID" class="form-control" required>
                            <option value="">-- Select Organizer --</option>
                            <% 
                                for (String[] org : dao.getAllOrganizers()) { 
                                    // Since OrganizerID is an int, we parse the string ID from the list
                                    boolean isSelected = isEdit && Integer.parseInt(org[0]) == event.getOrganizerID();
                            %>
                                <option value="<%= org[0] %>" <%= isSelected ? "selected" : "" %>>
                                    <%= org[1] %>
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="col-md-6 form-group">
                            <label>Event Format</label>
                            <select name="eventType" class="form-control" required>
                                <% 
                                    String[] formats = {"Club Activity", "Gathering", "Workshop", "Talk", "Volunteering", "Meeting", "Competition (General)", "Trip", "Ceremony", "Entrepreneurship", "Arts/Performance", "Seminar", "Sports (Competitive)", "Sports (Recreational)", "Exhibition"};
                                    for (String f : formats) {
                                %>
                                    <option value="<%= f %>" <%= (isEdit && f.equals(event.getEventType())) ? "selected" : "" %>><%= f %></option>
                                <% } %>
                            </select>
                        </div>
                </div>
                <div class="text-center" style="margin-top:20px;">
                    <button type="submit" class="submit-btn">
                        <%= isEdit ? "Update Event" : "Create Event" %>
                    </button>
                    <a href="ad_event.jsp" class="btn btn-link text-muted">Cancel</a>
                </div>
            </div>
        </div>
    </form>
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
    <script>
        function previewImage(event) {
            const reader = new FileReader();
            reader.onload = function(){
                const output = document.getElementById('preview');
                output.src = reader.result;
            };
            reader.readAsDataURL(event.target.files[0]);
        }
    </script>

</body>
</html>