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
    List<User> userList = userDAO.getAllUsers(); // Assuming you have this method
    
    EventDAO eventDAO = new EventDAO();
    List<String> allCampuses = eventDAO.getAllCampusesFromTable();
%>
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
        
    <header class="header-area header-sticky">
        <div class="container">
            <nav class="main-nav">
                <a href="admin_dashboard.jsp" class="logo"><em>Digitific</em></a>
                <ul class="nav">
                    <li><a href="admin_dashboard.jsp">Dashboard</a></li>
                    <li><a href="ad_event.jsp">Shows & Events</a></li>
                    <li><a href="users.jsp" class="active">Users</a></li>
                    <li><a href="LogoutServlet">Logout</a></li>
                </ul>        
            </nav>
        </div>
    </header>

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
                            <% for(String campus : allCampuses) { %>
                                <div class="form-check mb-1">
                                    <input class="form-check-input campus-filter" type="checkbox" value="<%= campus %>" id="u_<%= campus %>">
                                    <label class="form-check-label" for="u_<%= campus %>"><%= campus %></label>
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
                                    <th class="text-center">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody">
                                <% if(userList != null && !userList.isEmpty()) { 
                                    for(User u : userList) { %>
                                    <tr class="user-row" data-campus="<%= u.getCampusName() %>">
                                        <td class="font-weight-bold">#<%= u.getUserID() %></td>
                                        <td><strong><%= u.getFullName() %></strong><br><small class="text-muted"><%= u.getRole() %></small></td>
                                        <td>
                                            <div><%= u.getEmail() %></div>
                                            <small class="text-muted"><%= (u.getPhoneNumber() != null) ? u.getPhoneNumber() : "No Phone" %></small>
                                        </td>
                                        <td>
                                            <strong><%= u.getCampusName() %></strong><br>
                                            <small class="text-info"><%= u.getCampusState() %></small>
                                        </td>
                                        <td class="text-center">
                                            <a href="user-edit.jsp?id=<%= u.getUserID() %>" class="btn btn-sm btn-light"><i class="fa fa-pencil"></i></a>
                                            <button class="btn btn-sm btn-danger" onclick="confirmDelete('<%= u.getUserID() %>')"><i class="fa fa-trash"></i></button>
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
    </script>
</body>
</html>