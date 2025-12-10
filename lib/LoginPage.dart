import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plant/Home.dart';
import 'package:plant/LandingPage.dart';
import 'package:plant/RegisterPage.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Add controllers for text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Add loading state
  bool _isLoading = false;

  Future<void> testConnection() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.baseUrl}/api/login/'))
          .timeout(Duration(seconds: 5));
      print('Connection successful: ${response.statusCode}');
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  Future<void> _LoginUser() async {
    // Get input values
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse('${Config.baseUrl}/api/login/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the token and user data
        final String token = responseData['token'];
        final Map<String, dynamic> userData = responseData['user'];

        // Save the token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);

        // Navigate to the Home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Handle errors
        final errorData = json.decode(response.body);
        String errorMessage = 'Login failed: ${response.statusCode}';
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData.values.join('\n');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
    testConnection();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   leading:
      // ),
      body: Stack(
        children: [
          // Section 1: Leaf Image
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/WelcomeImage.png',
              width: screenWidth,
              height: screenHeight,
            ),
          ),

          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.05,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); // Handle back navigation
              },
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFDAE5DD),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: GestureDetector(
                      onTap: () {
                        // Perform logout action
                        Navigator.pop(context); // Close the dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LandingPage(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back_outlined,
                        size: 33,
                        color: Color(0xFF41734E),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Section 2: Custom Curved Container
          Positioned.fill(
            top: screenHeight * 0.15,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),

                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: screenHeight * 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            Positioned(
                              top: screenHeight * (-0.03), // 10% from top
                              right: 0,
                              child: Image.asset(
                                'assets/images/leaf.png',
                                width: screenWidth * 0.4,
                                height: screenHeight * 0.4,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(0.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(height: 0),
                                    Text(
                                      'Welcome Back',
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF41734E),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Log in youe account',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Color(0xFFA1A1A1),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),

                                    SizedBox(height: 80),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                          ),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFDAE5DD,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _emailController,
                                                    decoration: InputDecoration(
                                                      hintText: 'Email',
                                                      labelStyle: TextStyle(
                                                        color: Color(
                                                          0xFF41734E,
                                                        ),
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: Color(
                                                            0xFF41734E,
                                                          ),
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Color(
                                                                    0xFFDAE5DD,
                                                                  ),
                                                                ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Color(
                                                                    0xFF41734E,
                                                                  ),
                                                                ),
                                                          ),
                                                      prefixIcon: Icon(
                                                        Icons.email_outlined,
                                                        color: Color(
                                                          0xFF41734E,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFDAE5DD,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: TextField(
                                                    controller:
                                                        _passwordController,
                                                    obscureText: true,
                                                    decoration: InputDecoration(
                                                      hintText: 'Password',
                                                      labelStyle: TextStyle(
                                                        color: Color(
                                                          0xFF41734E,
                                                        ),
                                                      ),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .auto,
                                                      border: OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: Color(
                                                            0xFF41734E,
                                                          ),
                                                        ),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Color(
                                                                    0xFFDAE5DD,
                                                                  ),
                                                                ),
                                                          ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            borderSide:
                                                                BorderSide(
                                                                  color: Color(
                                                                    0xFF41734E,
                                                                  ),
                                                                ),
                                                          ),
                                                      prefixIcon: Icon(
                                                        Icons.lock_outline,
                                                        color: Color(
                                                          0xFF41734E,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 30,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF30625A),
                                          borderRadius: BorderRadius.circular(
                                            30.0,
                                          ), // Adjust border radius as needed
                                        ),
                                        child: TextButton(
                                          onPressed:
                                              _isLoading ? null : _LoginUser,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenHeight * 0.05,
                                              vertical: 11,
                                            ),
                                            backgroundColor:
                                                Colors
                                                    .transparent, // Make button background transparent
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                40.0,
                                              ), // Match container's border radius
                                            ),
                                          ),
                                          child:
                                              _isLoading
                                                  ? const CircularProgressIndicator(
                                                    color: Colors.white,
                                                  )
                                                  : const Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color:
                                                          Colors
                                                              .white, // Text color
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 30),
                                    Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              // Navigate to login page
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  EdgeInsets
                                                      .zero, // Remove default padding
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap, // Reduce tap target size
                                            ),
                                            child: const Text(
                                              "don't have an account?",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFFA1A1A1),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4,
                                          ), // Add a small spacing between the texts
                                          TextButton(
                                            onPressed: () {
                                              // Navigate to the RegisterPage
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          RegisterPage(),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  EdgeInsets
                                                      .zero, // Remove default padding
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap, // Reduce tap target size
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 10.0,
                                              ),
                                              child: const Text(
                                                'Sign up',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color(0xFF41734E),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, size.height * 0.15); // Start at left curve point
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.05, // Control point
      size.width * 0.5,
      size.height * 0.15, // End point
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.25, // Control point
      size.width,
      size.height * 0.15, // End point
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
