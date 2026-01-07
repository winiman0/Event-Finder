<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% request.setAttribute("activePage", "register"); %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="Tooplate">
    <link href="https://fonts.googleapis.com/css?family=Poppins:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i&display=swap" rel="stylesheet">

    <title>Digitific: Your Events</title>


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
            background: #faf6ef;
            font-family: 'Poppins', sans-serif;
            color: #262323;
        }
        
        .auth-container select {
            display: block;
            width: 100%;
            height: 45px;
            padding: 10px 15px;
            font-size: 14px;
            line-height: 1.42857143;
            color: #2a2a2a;
            background-color: #fff;
            border: 1px solid #eee;
            border-radius: 25px; /* Matches the rounded style of modern templates */
            margin-bottom: 30px;
            appearance: none; /* Removes default arrow to style it cleaner */
            -webkit-appearance: none;
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
        <%@ include file="header.jsp" %>
 <div class="auth-container">
        <h2>Register</h2>

        <form action="RegisterServlet" method="POST">
            <input type="text" name="studentID" placeholder="Student ID" required>
            <input type="text" name="fullname" placeholder="Full Name" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <select name="campus" required style="width: 100%; padding: 10px; margin-bottom: 20px; border: 1px solid #ccc; border-radius: 5px; background: white;">
                    <option value="" disabled selected>Select Your Campus</option>
                    <option value="SA01">Shah Alam</option>
                    <option value="CHND">Chendering</option>
                    <option value="MA01">Machang</option>
                    <option value="AR01">Arau</option>
                    <option value="DU01">Dungun</option>
                    <option value="PA01">Puncak Alam</option>
                    <option value="JG01">Jengka</option>
                    <option value="SG01">Segamat</option>
                </select>

            <button type="submit" class="auth-btn">Sign Up</button>
            <p>Already have an account? <a href="login.jsp">Login</a></p>
        </form>
            
            
            <% if(request.getAttribute("error") != null) { %>
            <p style="color:red;"><%= request.getAttribute("error") %></p>
            <% } %>
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

</body>
</html>
