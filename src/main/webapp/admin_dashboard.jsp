<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User"%>
<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equalsIgnoreCase(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Tooplate">
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i&display=swap" rel="stylesheet">

    <title>Dashboard</title>


    <!-- Additional CSS Files -->
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">

    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">

    <link rel="stylesheet" type="text/css" href="assets/css/owl-carousel.css">

    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
<!--

Tooplate 2125 ArtXibition

https://www.tooplate.com/view/2125-artxibition

-->
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
        padding: 25px;
        width: 32%;
        border-radius: 15px;
        text-align: center;
        box-shadow: 0px 4px 12px rgba(0,0,0,0.1);
        background-color: #fefcfb; /* soft off-white */
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
</style>


</head>
<body>
    <!-- ***** Header Area Start ***** -->
    <header class="header-area header-sticky">
        <div class="container">
            <div class="row">
                <div class="col-12">
                    <nav class="main-nav">
                        <!-- ***** Logo Start ***** -->
                        <a href="index.html" class="logo"><em>Digitific</em></a>
                        <!-- ***** Logo End ***** -->
                        <!-- ***** Menu Start <li><a href="tickets.html">Tickets</a></li> ***** -->
                        <ul class="nav">
                            <li><a href="index.jsp">Home</a></li>
                            <li><a href="admin_dashboard.jsp" class="active">Dashboard</a></li> 
                            <li><a href="ad_event.jsp">Shows & Events</a></li> 
                            <li><a href="users.jsp">Users</a></li> 
                            <li><a href="LogoutServlet">Logout</a></li>  
                        </ul>        
                        <a class='menu-trigger'>
                            <span>Menu</span>
                        </a>
                        <!-- ***** Menu End ***** -->
                    </nav>
                </div>
            </div>
        </div>
    </header>

    <!-- ***** Header Area End ***** -->
    <div class="dashboard-container">
        
        <div class="container-fluid">
            <div class="page-heading-rent-venue">
            <div class="col-lg-12">
                    <div class="section-heading">
                        <h2>Admin Dashboard</h2><br>
                    </div>
            </div>
        </div>
        <%
            com.event.dao.EventDAO dao = new com.event.dao.EventDAO();
            com.event.dao.UserDAO userDao = new com.event.dao.UserDAO();
            int totalEvents = dao.getCount("EVENT");
            int totalStudents = userDao.getStudentCount(); 
            int totalRegs = dao.getCount("REGISTRATION");
        %>
        <div class="counter-content dashboard-counter">
        <ul>
            <div class="stat-card"><li>Total Events<span id="stat-upcoming"><%= totalEvents %></span></li></div>
            <div class="stat-card"><li>Total Students<span id="stat-week"><%= totalStudents %></span></li></div>
            <div class="stat-card"><li>Registrations<span id="stat-joined"><%= totalRegs %></span></li></div>
        </ul>

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
                    <td><%= row[0] %></td>
                    <td><%= row[1] %></td>
                </tr>
            <% 
                    } 
                } 
            %>
        </table>

    </div>

</body>
</html>
