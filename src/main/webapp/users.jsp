<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="com.event.model.User, com.event.dao.UserDAO, com.event.dao.EventDAO, java.util.*"%>
<%
    // 1. Security Check
    User admin = (User) session.getAttribute("user");
    if (admin == null || !"admin".equalsIgnoreCase(admin.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 2. Fetch Data
    UserDAO userDAO = new UserDAO();
    List<User> userList = userDAO.getAllUsers();
    
    // Fetch from UserDAO instead of EventDAO
    List<String[]> allCampuses = userDAO.getAllCampusesForDropdown();
   
    request.setAttribute("activePage", "users");
    
    
    %>
    <%@ include file="header.jsp" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Digitific | Manage Users</title>
    <link rel="stylesheet" type="text/css" href="assets/css/bootstrap.min.css">
    <link rel="stylesheet" href="assets/css/tooplate-artxibition.css">
    <link rel="stylesheet" type="text/css" href="assets/css/font-awesome.css">
    <style>
        .main-content-wrapper {
            background-color: #faf6ef;
            min-height: 100vh;
            padding-top: 50px;
            padding-bottom: 80px;
        }
        .sidebar { 
            background: #fff; border-radius: 15px; border: none; 
            position: sticky; top: 100px; 
        }
        /* Modern Table Styling */
        .user-card-table {
            background: #fff;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 5px 15px rgba(0,0,0,0.05);
            border: none;
        }
        .table thead th {
            background-color: #c2acac;
            color: #fff;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 1px;
            padding: 15px;
            border: none;
        }
        .table td {
            vertical-align: middle;
            padding: 15px;
            color: #555;
            font-size: 14px;
            border-top: 1px solid #eee;
        }
        .user-id { font-weight: bold; color: #6c63ff; }
        .action-btns .btn {
            border-radius: 8px;
            padding: 5px 10px;
            margin-right: 5px;
        }
        .search-input {
            border-radius: 10px;
            border: 1px solid #ddd;
            padding: 10px 15px;
        }
        
        .pagination-wrapper { margin-top: 30px; display: flex; justify-content: center; }
        .pagination-btn { 
            padding: 8px 16px; border: 1px solid #ddd; background: #fff; 
            color: #333; margin: 0 4px; border-radius: 5px; cursor: pointer;
        }
        .pagination-btn.active { background: #c2acac; color: white; border-color: #c2acac; }
        .pagination-btn:disabled { opacity: 0.5; cursor: not-allowed; }
        .button-group {
            display: flex;
            gap: 8px;
            white-space: nowrap;
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
       

    <div class="page-heading-shows-events" style="background-image: url('assets/images/shows_eventsbg.jpg');">
        <div class="container">
            <div class="row">
                <div class="col-lg-12">
                    <h2>User Directory</h2>
                    <span>View, edit or delete registered users.</span>
                </div>
            </div>
        </div>
    </div>
    <%
        String msg = request.getParameter("msg");
        if(msg != null) {
            String alertClass = msg.equals("error") ? "alert-danger" : "alert-success";
            String messageText = "";
            if(msg.equals("updated")) messageText = "User updated successfully!";
            if(msg.equals("deleted")) messageText = "User removed successfully!";
            if(msg.equals("error")) messageText = "An error occurred. Please try again.";
    %>
        <div class="alert <%= alertClass %> alert-dismissible fade show" role="alert">
            <strong>Status:</strong> <%= messageText %>
            <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>
    <% } %>
    <div class="main-content-wrapper">
        <div class="container">
            <div class="row">
                <div class="col-lg-3">
                    <div class="sidebar card shadow-sm p-4">
                        <h5 class="mb-4">Quick Search</h5>
                        <input type="text" id="userSearch" class="form-control search-input" placeholder="Name or email...">
                        <hr>
                        <div class="filter-group mb-4">
                            <h6 class="small text-uppercase font-weight-bold text-muted mb-3">Filter by Campus</h6>
                            <div class="form-check mb-2">
                                <input class="form-check-input campus-filter" type="checkbox" value="all" id="allCamp" checked>
                                <label class="form-check-label" for="allCamp">All Campuses</label>
                            </div>
                            <% for(String[] campus : allCampuses) { %>
                                <div class="form-check mb-1">
                                    <%-- Use campus[1] for the Name and campus[0] for the ID --%>
                                    <input class="form-check-input campus-filter" type="checkbox" 
                                           value="<%= campus[1] %>" id="u_<%= campus[0] %>">
                                    <label class="form-check-label" for="u_<%= campus[0] %>">
                                        <%= campus[1] %>
                                    </label>
                                </div>
                            <% } %>
                        </div>
                        <button type="button" class="btn btn-sm btn-outline-dark w-100" onclick="resetUserFilters()">Clear Filters</button>
                    </div>
                </div>

                <div class="col-lg-9">
                    <div class="user-card-table">
                        <table class="table table-hover mb-0" id="userTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Full Name</th>
                                    <th>Email & Contact</th>
                                    <th>Campus</th>
                                    <th>Merit (Sem)</th> 
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if(userList != null && !userList.isEmpty()) { 
                                    for(User u : userList) { %>
                                <% 
                                    int points = userDAO.getUserTotalMerit(u.getUserID());
                                    List<String[]> history = userDAO.getMeritHistory(u.getUserID()); 
                                    boolean isRowUserAdmin = "admin".equalsIgnoreCase(u.getRole());
                                %>

                                <tr class="user-row" data-campus="<%= u.getCampusName() %>">
                                    <td class="font-weight-bold">#<%= u.getUserID() %></td>
                                    <td>
                                        <strong><%= u.getFullName() %></strong><br>
                                        <small class="text-muted"><%= u.getRole() %></small>
                                    </td>
                                    <td>
                                        <div><%= u.getEmail() %></div>
                                        <small class="text-muted"><%= (u.getPhoneNumber() != null) ? u.getPhoneNumber() : "No Phone" %></small>
                                    </td>
                                    <td>
                                        <strong><%= u.getCampusName() %></strong><br>
                                        <small class="text-info"><%= u.getCampusState() %></small>
                                    </td>

                                    <td>
                                        <% if (!isRowUserAdmin) { %>
                                            <span class="badge badge-success" style="font-size: 14px;">
                                                <%= points %> pts
                                            </span>
                                        <% } else { %>
                                            <span class="text-muted small">N/A</span>
                                        <% } %>
                                    </td>

                                    <td class="text-center">
                                        <div class="button-group">
                                            <button type="button" class="btn btn-sm btn-info" 
                                                    onclick="showLocalHistory('<%= u.getFullName() %>', this)"
                                                    data-history="<% 
                                                        if(history == null || history.isEmpty()){ %>No past records found<% } 
                                                        else { 
                                                            for(String[] h : history){ %><%= h[0] %> (<%= h[1] %> pts), <% }
                                                        } %>">
                                                <i class="fa fa-history"></i>
                                            </button>

                                            <button type="button" class="btn btn-sm btn-light" 
                                                    onclick="openEditModal('<%= u.getUserID() %>', '<%= u.getFullName() %>', '<%= u.getEmail() %>', '<%= u.getPhoneNumber() %>', '<%= u.getCampusID() %>', '<%= u.getRole() %>', '<%= u.getFaculty() %>')" title="Edit User">
                                                <i class="fa fa-pencil"></i>
                                            </button>

                                            <button type="button" class="btn btn-sm btn-danger" 
                                                    onclick="openDeleteModal('<%= u.getUserID() %>', '<%= u.getFullName() %>')" title="Delete User">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="pagination-wrapper" id="paginationControls"></div>
                </div>
            </div>
        </div>
    </div>
                            
    <div class="modal fade" id="editUserModal" tabindex="-1" role="dialog" aria-labelledby="editUserModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content" style="border-radius: 15px;">
                <div class="modal-header" style="background-color: #c2acac; color: white; border-top-left-radius: 15px; border-top-right-radius: 15px;">
                    <h5 class="modal-title" id="editUserModalLabel">Edit User Details</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true" style="color: white;">&times;</span>
                    </button>
                </div>
                <form action="UserUpdateServlet" method="POST">
                    <div class="modal-body">
                        <div class="form-group">
                            <label>User ID</label>
                            <input type="text" name="userId" id="editUserId" class="form-control" readonly style="background-color: #eee;">
                        </div>
                        <div class="form-group">
                            <label>Full Name</label>
                            <input type="text" name="fullName" id="editFullName" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="email" id="editEmail" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Phone Number</label>
                            <input type="text" name="phone" id="editPhone" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Campus</label>
                            <select name="campus" id="editCampus" class="form-control">
                                <% for(String[] c : allCampuses) { %>
                                    <option value="<%= c[0] %>"><%= c[1] %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Faculty</label>
                            <select name="faculty" id="editFaculty" class="form-control">
                                <option value="FKSW">FKSW - Computer Science</option>
                                <option value="FKP">FKP - Management</option>
                                <option value="FKE">FKE - Engineering</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Role</label>
                            <select name="role" id="editRole" class="form-control">
                                <option value="student">Student</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" style="background-color: #c2acac; border: none;">Save Changes</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
                            
    <div class="modal fade" id="meritHistoryModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-md" role="document">
            <div class="modal-content" style="border-radius: 15px;">
                <div class="modal-header" style="background-color: #6c63ff; color: white; border-top-left-radius: 15px; border-top-right-radius: 15px;">
                    <h5 class="modal-title">Merit History: <span id="historyUserName"></span></h5>
                    <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
                </div>
                <div class="modal-body">
                    <div id="meritLoading" class="text-center d-none">
                        <div class="spinner-border text-primary" role="status"></div>
                    </div>
                    <div id="historyContent"></div>
                </div>
            </div>
        </div>
    </div>
                            
                            <div class="modal fade" id="deleteUserModal" tabindex="-1" role="dialog" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content" style="border-radius: 15px;">
            <div class="modal-header bg-danger text-white" style="border-top-left-radius: 15px; border-top-right-radius: 15px;">
                <h5 class="modal-title">Confirm Deletion</h5>
                <button type="button" class="close text-white" data-dismiss="modal">&times;</button>
            </div>
            <div class="modal-body text-center p-4">
                <i class="fa fa-exclamation-triangle fa-3x text-warning mb-3"></i>
                <p>Are you sure you want to delete user <br><strong id="deleteUserName"></strong> (#<span id="deleteUserIdDisplay"></span>)?</p>
                <p class="text-muted small">This action cannot be undone and may remove their event registrations.</p>
            </div>
            <div class="modal-footer">
                <form action="UserDeleteServlet" method="POST">
                    <input type="hidden" name="userId" id="hiddenDeleteId">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">Yes, Delete User</button>
                </form>
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
    <script src="assets/js/popper.js"></script>
    <script src="assets/js/scrollreveal.min.js"></script>
    <script src="assets/js/waypoints.min.js"></script>
    <script src="assets/js/jquery.counterup.min.js"></script>
    <script src="assets/js/imgfix.min.js"></script> 
    <script src="assets/js/mixitup.js"></script> 
    <script src="assets/js/accordions.js"></script>
    <script src="assets/js/owl-carousel.js"></script>
    <script src="assets/js/custom.js"></script>

    <script>
        const rowsPerPage = 20;
        let currentPage = 1;

        // FIX: Using standard string concatenation (+) instead of backticks to avoid JSP EL errors
        function renderPagination(totalPages) {
            const container = document.getElementById('paginationControls');
            container.innerHTML = '';
            if (totalPages <= 1) return;

            for (let i = 1; i <= totalPages; i++) {
                const btn = document.createElement('button');
                btn.innerText = i;

     
                let className = "pagination-btn";
                if (i === currentPage) {
                    className += " active";
                }
                btn.className = className;

                btn.onclick = function() { 
                    currentPage = i; 
                    displayTable(); 
                };
                container.appendChild(btn);
            }
        }

        function displayTable() {
            const rows = Array.from(document.querySelectorAll('.user-row'));
            // Filter rows based on our custom 'data-filtered' attribute
            const visibleRows = rows.filter(row => row.getAttribute('data-filtered') !== 'true');

            const totalPages = Math.ceil(visibleRows.length / rowsPerPage);

            // Hide all rows first
            rows.forEach(row => row.style.display = 'none');

            // Show only the 20 rows for the current page
            const start = (currentPage - 1) * rowsPerPage;
            const end = start + rowsPerPage;

            visibleRows.slice(start, end).forEach(row => {
                row.style.display = '';
            });

            renderPagination(totalPages);
        }

        function applyFilters() {
            const searchValue = document.getElementById('userSearch').value.toLowerCase();

            // Get all checked campus values
            const selectedCheckboxes = document.querySelectorAll('.campus-filter:checked');
            const selectedValues = Array.from(selectedCheckboxes).map(cb => cb.value);

            const rows = document.querySelectorAll('.user-row');

            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                const campus = row.getAttribute('data-campus');

                const matchesSearch = text.includes(searchValue);
                const matchesCampus = selectedValues.includes('all') || selectedValues.includes(campus);

                if (matchesSearch && matchesCampus) {
                    row.setAttribute('data-filtered', 'false');
                } else {
                    row.setAttribute('data-filtered', 'true');
                }
            });

            currentPage = 1; // Reset to page 1 whenever user searches or filters
            displayTable();
        }

        // Single set of Event Listeners
        document.getElementById('userSearch').addEventListener('keyup', applyFilters);

        document.querySelectorAll('.campus-filter').forEach(cb => {
            cb.addEventListener('change', function() {
                // If "All" is checked, uncheck others. If others checked, uncheck "All"
                if(this.value === 'all' && this.checked) {
                    document.querySelectorAll('.campus-filter').forEach(c => {
                        if(c.value !== 'all') c.checked = false;
                    });
                } else if (this.checked) {
                    document.getElementById('allCamp').checked = false;
                }
                applyFilters();
            });
        });

        function confirmDelete(id) {
            if(confirm("Are you sure you want to delete user " + id + "?")) {
                window.location.href = "UserDeleteServlet?id=" + id;
            }
        }

        function resetUserFilters() {
            document.getElementById('userSearch').value = '';
            document.querySelectorAll('.campus-filter').forEach(cb => {
                cb.checked = (cb.value === 'all');
            });
            applyFilters();
        }

        // Run on Load
        window.onload = function() {
            applyFilters(); 
        };
        
        function openEditModal(id, name, email, phone, campusID, role, faculty) {
            document.getElementById('editUserId').value = id;
            document.getElementById('editFullName').value = name;
            document.getElementById('editEmail').value = email;
            document.getElementById('editPhone').value = (phone === 'null' || !phone) ? "" : phone;

            // Set the dropdowns
            document.getElementById('editCampus').value = campusID; 
            document.getElementById('editRole').value = role.toLowerCase();
            document.getElementById('editFaculty').value = faculty; // Make sure 'faculty' matches the <option value> exactly

            $('#editUserModal').modal('show');
        }
        
        function openDeleteModal(id, name) {
            document.getElementById('deleteUserIdDisplay').innerText = id;
            document.getElementById('deleteUserName').innerText = name;
            document.getElementById('hiddenDeleteId').value = id;
            $('#deleteUserModal').modal('show');
        }
        
        function showLocalHistory(userName, btn) {
            document.getElementById('historyUserName').innerText = userName;
            const historyData = btn.getAttribute('data-history');
            const content = document.getElementById('historyContent');

            // Pecahkan data dan buat table simple
            let html = '<ul class="list-group">';
            const items = historyData.split(', ');
            items.forEach(item => {
                if(item.trim() !== "") {
                    html += '<li class="list-group-item">' + item + '</li>';
                }
            });
            html += '</ul>';

            content.innerHTML = html;
            $('#meritHistoryModal').modal('show');
        }
    </script>
</body>
</html>