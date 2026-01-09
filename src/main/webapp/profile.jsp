<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User, com.event.dao.UserDAO, java.util.*"%>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Now the JSP knows where to find UserDAO and List!
    UserDAO uDao = new UserDAO();
    int totalMerit = uDao.getUserTotalMerit(user.getUserID());
    List<String[]> meritHistory = uDao.getMeritHistory(user.getUserID());
%>

<%@ include file="header.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Digitific | Profile</title>
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">

    <style>
        body { background-color: #bdc8a8; color: #333; }
        
        /* Professional Card Style */
        .profile-card {
            background: #ffffff;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.08);
            padding: 30px;
        }

        .info-label {
            font-size: 0.85rem;
            color: #6c757d;
            text-transform: uppercase;
            font-weight: 600;
            display: block;
            margin-bottom: 2px;
        }

        .info-value {
            font-size: 1.1rem;
            font-weight: 500;
            color: #212529;
            margin-bottom: 20px;
        }

        /* Merit Section */
        .merit-badge-container {
            background: #f0f7ff;
            border: 1px solid #d0e3ff;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: 0.2s;
        }
        .merit-badge-container:hover { background: #e2efff; }
        .merit-number { font-size: 3rem; font-weight: 800; color: #007bff; }
        
        .section-title {
            border-bottom: 2px solid #007bff;
            display: inline-block;
            margin-bottom: 25px;
            padding-bottom: 5px;
            font-weight: 700;
        }
    </style>
</head>

<body>
    <div class="page-heading-shows-events">
        <div class="container">
            <h2>Account Profile</h2>
            <span>Official student record and achievement tracking.</span>
        </div>
    </div>

    <div class="container mt-5 mb-5">
        <div class="row">
            <div class="col-lg-4">
                <div class="profile-card text-center mb-4">
                    <h5 class="mb-3">Academic Merit</h5>
                    <div class="merit-badge-container" data-toggle="modal" data-target="#meritModal">
                        <span class="info-label">Current Balance</span>
                        <div class="merit-number"><%= totalMerit %></div>
                        <small class="text-primary"><i class="fa fa-history"></i> View Point History</small>
                    </div>
                </div>
            </div>

            <div class="col-lg-8">
                <div class="profile-card">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h4 class="section-title">Personal Information</h4>
                        <button class="btn btn-primary btn-sm" data-toggle="modal" data-target="#editProfileModal">
                            <i class="fa fa-pencil"></i> Edit Profile
                        </button>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <label class="info-label">Student ID</label>
                            <p class="info-value"><%= user.getUserID() %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="info-label">Full Name (As per IC)</label>
                            <p class="info-value"><%= user.getFullName() %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="info-label">Official Email</label>
                            <p class="info-value"><%= user.getEmail() %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="info-label">Contact Number</label>
                            <p class="info-value"><%= (user.getPhoneNumber() != null) ? user.getPhoneNumber() : "---" %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="info-label">Faculty</label>
                            <p class="info-value"><%= (user.getFaculty() != null) ? user.getFaculty() : "Not Specified" %></p>
                        </div>
                        <div class="col-md-6">
                            <label class="info-label">Campus</label>
                            <p class="info-value"><%= user.getCampusID() %></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editProfileModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Account Details</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <form action="UpdateProfileServlet" method="POST">
                    <div class="modal-body">
                        <div class="alert alert-info py-2" style="font-size: 0.85rem;">
                            <i class="fa fa-info-circle"></i> Student ID cannot be modified. Name must match your IC.
                        </div>
                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" class="form-control" value="<%= user.getFullName() %>" required>
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" class="form-control" value="<%= user.getEmail() %>" required>
                        </div>
                        <div class="form-group">
                            <label>Phone Number</label>
                            <input type="text" name="phone" class="form-control" value="<%= user.getPhoneNumber() %>">
                        </div>
                        <div class="form-group">
                            <label>Faculty</label>
                            <select name="faculty" class="form-control">
                                <option value="FKSW" <%= "FKSW".equals(user.getFaculty()) ? "selected" : "" %>>FKSW - Computer Science</option>
                                <option value="FKP" <%= "FKP".equals(user.getFaculty()) ? "selected" : "" %>>FKP - Management</option>
                                <option value="FKE" <%= "FKE".equals(user.getFaculty()) ? "selected" : "" %>>FKE - Engineering</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="meritModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-light">
                    <h5 class="modal-title">Merit Point History</h5>
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body p-0">
                    <table class="table mb-0">
                        <thead class="thead-light">
                            <tr>
                                <th>Event Name</th>
                                <th class="text-right">Points</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (meritHistory.isEmpty()) { %>
                                <tr>
                                    <td colspan="2" class="text-center text-muted">No merits earned yet. Join an event!</td>
                                </tr>
                            <% } else { 
                                for (String[] record : meritHistory) { %>
                                <tr>
                                    <td><%= record[0] %></td>
                                    <td class="text-right text-success">+<%= record[1] %></td>
                                </tr>
                            <% } 
                            } %>
                        </tbody>
                    </table>
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
</body>
</html>