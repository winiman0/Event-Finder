<%@page import="com.event.model.User"%>
<%
    // 1. Get user from session
    User navUser = (User) session.getAttribute("user");
    String role = (navUser != null) ? navUser.getRole() : "guest";

    // 2. Get the active page variable (set by the including page)
    String active = (String) request.getAttribute("activePage");
    if (active == null) active = ""; 
%>

<header class="header-area header-sticky">
    <div class="container">
        <div class="row">
            <div class="col-12">
                <nav class="main-nav">
                    <a href="index.jsp" class="logo"><em>Digitific</em></a>
                    
                    <ul class="nav">
                        <%-- HOME (Available to everyone) --%>
                        <li><a href="index.jsp" class="<%= active.equals("home") ? "active" : "" %>">Home</a></li>

                        <%-- ADMIN VIEW --%>
                        <% if ("admin".equalsIgnoreCase(role)) { %>
                            <li><a href="admin_dashboard.jsp" class="<%= active.equals("dashboard") ? "active" : "" %>">Dashboard</a></li>
                            <li><a href="manage_participants.jsp" class="<%= active.equals("participants") ? "active" : "" %>">Participants</a></li>
                            <li><a href="ad_event.jsp" class="<%= active.equals("events") ? "active" : "" %>">Shows & Events</a></li>
                            <li><a href="users.jsp" class="<%= active.equals("users") ? "active" : "" %>">Users</a></li>

                        <%-- STUDENT / USER VIEW --%>
                        <% } else if ("student".equalsIgnoreCase(role) || "user".equalsIgnoreCase(role)) { %>
                            <li><a href="ad_event.jsp" class="<%= active.equals("events") ? "active" : "" %>">Shows & Events</a></li>
                            <li><a href="event_list.jsp" class="<%= active.equals("myevents") ? "active" : "" %>">Your Events</a></li>
                            <li><a href="profile.jsp" class="<%= active.equals("profile") ? "active" : "" %>">Profile</a></li>

                        <%-- GUEST VIEW --%>
                        <% } else { %>
                            <li><a href="ad_event.jsp" class="<%= active.equals("events") ? "active" : "" %>">Shows & Events</a></li>
                            <li><a href="login.jsp" class="<%= active.equals("login") ? "active" : "" %>">Login</a></li>
                            <li><a href="register.jsp" class="<%= active.equals("register") ? "active" : "" %>">Register</a></li>
                        <% } %>

                        <%-- LOGOUT (Only if logged in) --%>
                        <% if (!"guest".equals(role)) { %>
                            <li><a href="LogoutServlet" style="color: #fb3f3f;">Logout</a></li>
                        <% } %>
                    </ul>        
                    <a class='menu-trigger'><span>Menu</span></a>
                </nav>
            </div>
        </div>
    </div>
</header>