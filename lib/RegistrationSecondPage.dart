import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant/Home.dart';
import 'package:plant/LoginPage.dart';
import 'package:plant/RegisterPage.dart';
import 'dart:convert';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationSecondPage extends StatefulWidget {
  final Map<String, dynamic> firstPageData;

  const RegistrationSecondPage({super.key, required this.firstPageData});

  @override
  State<RegistrationSecondPage> createState() => _RegistrationSecondPageState();
}

class _RegistrationSecondPageState extends State<RegistrationSecondPage> {
  // Controllers for second page fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _specialityController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthPlaceController = TextEditingController();

  final TextEditingController _fullNameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _completeRegistration() async {
    // Validate second page fields
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (_specialityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your speciality')),
      );
      return;
    }

    if (_birthDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your birth date')),
      );
      return;
    }

    if (_birthPlaceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your birth place')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine data from both pages
      final Map<String, dynamic> registrationData = {
        ...widget.firstPageData,
        'full_name': _fullNameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'speciality': _specialityController.text.trim(),
        'birth_date': _birthDateController.text.trim(),
        'birth_place': _birthPlaceController.text.trim(),
      };

      final response = await http
          .post(
            Uri.parse('${Config.baseUrl}/api/register/'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(registrationData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        // Parse the response
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Extract the token
        final String token = responseData['token'];

        // Save the token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);

        // Registration successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Handle errors
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Registration failed: ${response.statusCode}';
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData.values.join('\n');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
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
            top: 0,
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
                                            builder:
                                                (context) => RegisterPage(),
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
                          Positioned(
                            top: screenHeight * (0.03),
                            right: 0,
                            child: Image.asset(
                              'assets/images/leaf.png',
                              width: screenWidth * 0.34,
                              height: screenHeight * 0.34,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 80.0),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SizedBox(height: 0),
                                  Text(
                                    'Complete Registration',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF64806B),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'for better experience',
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Color(0xFFA1A1A1),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  const SizedBox(height: 40),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 20),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller: _fullNameController,
                                                decoration: InputDecoration(
                                                  hintText: 'Full name',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto,
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
                                                    Icons.person_outline,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            // Phone Number Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextFormField(
                                                controller: _phoneController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                decoration: InputDecoration(
                                                  hintText: 'Phone Number',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
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
                                                    Icons
                                                        .phone_android_outlined,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Phone number is required';
                                                  } else if (value.length !=
                                                      10) {
                                                    return 'Phone number must be exactly 10 digits long';
                                                  } else if (!value.startsWith(
                                                    '0',
                                                  )) {
                                                    return 'Phone number must start with 0';
                                                  } else if (!RegExp(
                                                    r'^0\d{9}$',
                                                  ).hasMatch(value)) {
                                                    return 'Invalid phone number format';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),

                                            const SizedBox(height: 20),

                                            // Speciality Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller:
                                                    _specialityController,
                                                decoration: InputDecoration(
                                                  hintText: 'Speciality',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto,
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
                                                    Icons.work_outline,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            // Birth Date Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller:
                                                    _birthDateController,
                                                readOnly: true,
                                                onTap: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                        context: context,
                                                        initialDate: DateTime(
                                                          2007,
                                                        ),
                                                        firstDate: DateTime(
                                                          1900,
                                                        ),
                                                        lastDate: DateTime(
                                                          2007,
                                                        ),
                                                      );

                                                  if (pickedDate != null) {
                                                    _birthDateController.text =
                                                        "${pickedDate.year}-${pickedDate.month}-${pickedDate.day}";
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  hintText: 'Birth Date',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
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
                                                    Icons.date_range_outlined,
                                                    color: Color(0xFF41734E),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),

                                            // Birth Place Field
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFDAE5DD),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: TextField(
                                                controller:
                                                    _birthPlaceController,
                                                decoration: InputDecoration(
                                                  hintText: 'Birth Place',
                                                  labelStyle: TextStyle(
                                                    color: Color(0xFF41734E),
                                                  ),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .auto,
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
                                                    Icons.location_on_outlined,
                                                    color: Color(0xFF41734E),
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

                                  // Sign Up Button
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
                                            _isLoading
                                                ? null
                                                : _completeRegistration,
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
                                                  'Sign Up',
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
                                            '2',
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
        ],
      ),
    );
  }
}
