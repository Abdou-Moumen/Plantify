import 'package:flutter/material.dart';
import 'package:plant/LandingPage.dart';
import 'package:plant/LoginPage.dart';
import 'package:plant/RegistrationSecondPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for first page only
  // final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validate first page data
  bool _validateFirstPage() {
    // Basic validation
    // if (_fullNameController.text.trim().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please enter your full name')),
    //   );
    //   return false;
    // }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return false;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a password')));
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return false;
    }

    return true;
  }

  // Move to second page with current data
  void _goToSecondPage() {
    if (_validateFirstPage()) {
      // Create data map for the first page
      final Map<String, dynamic> firstPageData = {
        // 'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'password2': _confirmPasswordController.text,
      };

      // Navigate to second page and pass the data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => RegistrationSecondPage(firstPageData: firstPageData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            top: 20,
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
                padding: EdgeInsets.only(top: screenHeight * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Positioned(
                            top: screenHeight * (0.03),
                            right: 0,
                            child: Image.asset(
                              'assets/images/leaf.png',
                              width: screenWidth * 0.34,
                              height: screenHeight * 0.34,
                            ),
                          ),
                          Positioned(
                            top: screenHeight * 0,
                            left: screenWidth * 0.04,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFDAE5DD),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Perform logout action
                                        Navigator.pop(
                                          context,
                                        ); // Close the dialog
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => LandingPage(),
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.arrow_back_outlined,
                                        size: 30,
                                        color: const Color(0xFF41734E),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 0),
                                  Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64806B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Create your new account',
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
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),

                                            // Email Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller: _emailController,
                                                decoration: InputDecoration(
                                                  hintText: 'Email',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
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
                                                      color: Color(0xFF41734E),
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        borderSide: BorderSide(
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
                                                        borderSide: BorderSide(
                                                          color: Color(
                                                            0xFF41734E,
                                                          ),
                                                        ),
                                                      ),
                                                  prefixIcon: Icon(
                                                    Icons.email_outlined,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Password Field
                                            // Password Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller: _passwordController,
                                                obscureText: _obscurePassword,
                                                decoration: InputDecoration(
                                                  hintText: 'Password',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
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
                                                      color: Color(0xFF41734E),
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        borderSide: BorderSide(
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
                                                        borderSide: BorderSide(
                                                          color: Color(
                                                            0xFF41734E,
                                                          ),
                                                        ),
                                                      ),
                                                  prefixIcon: Icon(
                                                    Icons.lock_outline,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      size: 20,
                                                      _obscurePassword
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Color.fromARGB(
                                                        255,
                                                        104,
                                                        123,
                                                        109,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscurePassword =
                                                            !_obscurePassword;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Confirm Password Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller:
                                                    _confirmPasswordController,
                                                obscureText:
                                                    _obscureConfirmPassword,
                                                decoration: InputDecoration(
                                                  hintText: 'Confirm Password',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
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
                                                      color: Color(0xFF41734E),
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        borderSide: BorderSide(
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
                                                        borderSide: BorderSide(
                                                          color: Color(
                                                            0xFF41734E,
                                                          ),
                                                        ),
                                                      ),
                                                  prefixIcon: Icon(
                                                    Icons.lock_outline,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      size: 20,
                                                      _obscureConfirmPassword
                                                          ? Icons.visibility_off
                                                          : Icons.visibility,
                                                      color: Color.fromARGB(
                                                        255,
                                                        104,
                                                        123,
                                                        109,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _obscureConfirmPassword =
                                                            !_obscureConfirmPassword;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 30),

                                  // Next Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF30625A),
                                        borderRadius: BorderRadius.circular(
                                          30.0,
                                        ),
                                      ),
                                      child: TextButton(
                                        onPressed:
                                            _isLoading ? null : _goToSecondPage,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenHeight * 0.05,
                                            vertical: 11,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              40.0,
                                            ),
                                          ),
                                        ),
                                        child:
                                            _isLoading
                                                ? const CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                                : const Text(
                                                  'Next',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0,
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(child: Divider()),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            'Your registration progress',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Divider()),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 30),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD8E3DB,
                                          ), // Background color
                                          shape:
                                              BoxShape
                                                  .circle, // Make the background circular
                                        ),
                                        child: Center(
                                          child: Text(
                                            '1',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Text(
                                        'OF',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF41734E),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),

                                      const SizedBox(width: 20),
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD8E3DB,
                                          ), // Background color
                                          shape:
                                              BoxShape
                                                  .circle, // Make the background circular
                                        ),
                                        child: Center(
                                          child: Text(
                                            '2',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Color.fromARGB(
                                                255,
                                                120,
                                                120,
                                                120,
                                              ),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Login redirection
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 22.0,
                                    ),
                                    child: Center(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                            ),
                                            child: Text(
                                              "Already have an account?",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFFA1A1A1),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          TextButton(
                                            onPressed: () {
                                              // Navigate to the RegisterPage
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => LoginPage(),
                                                ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                right: 5.0,
                                              ),
                                              child: const Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xFF41734E),
                                                  fontWeight: FontWeight.bold,
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

          // Back button
          // Positioned(
          //   top: screenHeight * 0.06,
          //   left: screenWidth * 0.05,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.pop(context);
          //     },
          //     child: Padding(
          //       padding: const EdgeInsets.all(12.0),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: const Color.fromARGB(255, 204, 206, 205),
          //           borderRadius: BorderRadius.circular(60),
          //         ),
          //         child: Padding(
          //           padding: const EdgeInsets.all(5.0),
          //           child: GestureDetector(
          //             onTap: () {
          //               // Perform logout action
          //               Navigator.pop(context); // Close the dialog
          //               Navigator.pushReplacement(
          //                 context,
          //                 MaterialPageRoute(
          //                   builder: (context) => LandingPage(),
          //                 ),
          //               );
          //             },
          //             child: Icon(
          //               Icons.arrow_back_outlined,
          //               size: 30,
          //               color: const Color(0xFF41734E),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
