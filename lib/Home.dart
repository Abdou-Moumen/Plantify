import 'package:flutter/material.dart';
import 'package:plant/Chatpage.dart';
import 'package:plant/CustomGalleryPicker.dart';
import 'package:plant/History.dart';
import 'package:plant/LoginPage.dart';
import 'package:plant/PlantDetail.dart';
import 'package:plant/ProfilePage.dart';
import 'package:plant/SettingsPage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:plant/api_service.dart';
import 'package:plant/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0; // Track the selected index

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _dividerAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _card1Animation;
  late Animation<double> _card2Animation;
  late Animation<double> _card3Animation;
  late Animation<double> _navBarAnimation;

  // List of icon paths for inactive and active states
  final List<Map<String, String>> _icons = [
    {
      'inactive': 'assets/icons/home.png',
      'active': 'assets/icons/homeActive.png',
    },
    {'inactive': 'assets/icons/chat.png', 'active': 'assets/icons/chat.png'},
    {
      'inactive': 'assets/icons/camera.png',
      'active': 'assets/icons/camera.png',
    },
    {
      'inactive': 'assets/icons/community.png',
      'active': 'assets/icons/communityActive.png',
    },
    {
      'inactive': 'assets/icons/profile.png',
      'active': 'assets/icons/profile.png',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for different elements
    _headerAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.3, curve: Curves.easeOutQuint),
      ),
    );

    _dividerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.4, curve: Curves.easeInOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 0.5, curve: Curves.easeInOut),
      ),
    );

    _card1Animation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.4, 0.6, curve: Curves.easeOutQuint),
      ),
    );

    _card2Animation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    _card3Animation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.6, 0.8, curve: Curves.easeOutQuint),
      ),
    );

    _navBarAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.7, 1.0, curve: Curves.easeOutQuint),
      ),
    );

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processImage(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Try to validate if the image is a plant image before sending to server
      bool isPlantImage = await _isLikelyPlantImage(imageFile);

      if (!isPlantImage) {
        Navigator.pop(context); // Close loading dialog
        await showCustomDialog(
          context: context,
          message:
              'Please upload an image of a plant leaf. The current image does not appear to be a plant.',
          isError: true,
        );
        return;
      }

      final prediction = await ApiService.predictDisease(imageFile);
      Navigator.pop(context); // Close loading dialog

      // Check if the prediction has low confidence
      if (prediction.containsKey('is_reliable') &&
          prediction['is_reliable'] == false) {
        // Show dialog indicating low confidence and asking for a better plant image
        await showCustomDialog(
          context: context,
          message:
              'Please upload a clearer image of a plant leaf. The current image could not be identified with confidence.',
          isError: true,
        );
        return; // Don't proceed to PlantDetail page
      }

      // Navigate to PlantDetail with the prediction data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PlantDetail(
                diseaseId: prediction['plant_disease'],
                isDefaultDisease: prediction['disease_details']['is_default'],
                predictedClass: prediction['predicted_class'],
                diseaseDetails: prediction['disease_details'],
              ),
        ),
      );

      // Show success message (optional)
      showCustomDialog(
        context: context,
        message: 'Plant disease identified successfully!',
        isError: false,
      );
    } catch (e) {
      Navigator.pop(context); // Ensure loading dialog is closed on error

      // Show a user-friendly message instead of the error
      showCustomDialog(
        context: context,
        message:
            e.toString().contains('Authentication failed')
                ? 'Session expired - please login again'
                : 'Please upload a clear image of a plant leaf. The current image cannot be processed.',
        isError: true,
      );

      if (e.toString().contains('Authentication failed')) {
        _handleAuthError(context);
      }
    }
  }

  // Simple method to check if image is likely a plant image
  // This is a basic check that can be improved later
  Future<bool> _isLikelyPlantImage(File imageFile) async {
    try {
      // Basic file size and format validation
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // File too large (>10MB)
        return false;
      }

      // Could add more sophisticated checks here in the future

      return true;
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  void _handleAuthError(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Session expired - please login again')),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (pickedFile != null) {
                    await _processImage(File(pickedFile.path));
                  }
                },
                icon: Icon(Icons.photo_library, color: Color(0xFF517159)),
                label: Text('Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  // elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final pickedFile = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (pickedFile != null) {
                    await _processImage(File(pickedFile.path));
                  }
                },
                icon: Icon(Icons.camera_alt, color: Color(0xFF517159)),
                label: Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  // elevation: 2,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        break;
      case 1: // Chat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatPage()),
        );
        break;
      case 2:
        _showImageSourceActionSheet(context);
        break;
      case 3: // History
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => History()),
        );
        break;
      case 4: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7), // Set page background color
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // Top Section (Fixed)
              Positioned(
                top:
                    screenHeight * 0.08 +
                    _headerAnimation.value, // 8% from the top with animation
                left: 35,
                right: 35,
                child: Opacity(
                  opacity: 1 - _headerAnimation.value.abs() / 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Ai Plant', style: TextStyle(fontSize: 24)),
                      GestureDetector(
                        onTap: () {
                          // Navigate to the Settings page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.settings_outlined, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: screenHeight * 0.15, // 8% from the top
                left: 35,
                right: 35,
                child: Opacity(
                  opacity: _dividerAnimation.value,
                  child: Divider(
                    color: Colors.grey.withOpacity(0.5),
                    thickness: 1.5,
                  ),
                ),
              ),

              Positioned(
                top: screenHeight * 0.2, // 18% from the top
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _titleAnimation.value,
                  child: Transform.scale(
                    scale: 0.8 + (_titleAnimation.value * 0.2),
                    child: const Center(
                      child: Text(
                        'What we offer ?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Scrollable Section (Starts at 30% from the top)
              Positioned(
                top: screenHeight * 0.27, // 30% from the top
                left: 0,
                right: 0,
                bottom: 0, // Extend to the bottom of the screen
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Animated containers
                      Transform.translate(
                        offset: Offset(0, _card1Animation.value),
                        child: Opacity(
                          opacity: 1 - _card1Animation.value / 100,
                          child: _buildCustomContainer(
                            screenWidth,
                            firstText: 'Update',
                            secondText: 'Pictures',
                            firstTextColor: Colors.black,
                            secondTextColor: const Color(0xFF517159),
                            imagePath: 'assets/Home/cameraHome.png',
                            child: const Column(children: []),
                            paragraphText:
                                'Upload plant photos for quick disease identification and diagnosis.',
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: Offset(0, _card2Animation.value),
                        child: Opacity(
                          opacity: 1 - _card2Animation.value / 100,
                          child: _buildCustomContainer(
                            screenWidth,
                            firstText: 'Get',
                            secondText: 'Recommendations',
                            firstTextColor: Colors.black,
                            secondTextColor: const Color(0xFF517159),
                            imagePath: 'assets/Home/recommondation.png',
                            child: const Column(children: []),
                            paragraphText:
                                'Get personalized care tips and treatment options for your plants.',
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: Offset(0, _card3Animation.value),
                        child: Opacity(
                          opacity: 1 - _card3Animation.value / 100,
                          child: _buildCustomContainer(
                            screenWidth,
                            firstText: 'Use our AI',
                            secondText: 'Chatbot',
                            firstTextColor: Colors.black,
                            secondTextColor: const Color(0xFF517159),
                            imagePath: 'assets/Home/chatbot.png',
                            child: const Column(children: []),
                            paragraphText:
                                'Ask questions and get expert plant advice from our AI assistant.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _navBarAnimation.value),
            child: Opacity(
              opacity: 1 - _navBarAnimation.value / 50,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white, // Set navigation bar background to white
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent, // Add a subtle shadow
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  items:
                      _icons.map((icon) {
                        return BottomNavigationBarItem(
                          icon: Image.asset(
                            icon['inactive']!,
                            width: 24,
                            height: 24,
                          ),
                          activeIcon: Image.asset(
                            icon['active']!,
                            width: 24,
                            height: 24,
                          ),
                          label: '', // Optional: Add labels if needed
                        );
                      }).toList(),
                  selectedItemColor: const Color(
                    0xFF41734E,
                  ), // Customize selected color
                  showSelectedLabels: false, // Hide labels for a cleaner look
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor:
                      Colors.white, // Ensure navigation bar background is white
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomContainer(
    double screenWidth, {
    required String firstText,
    required String secondText,
    required Color firstTextColor,
    required Color secondTextColor,
    required String imagePath,
    required String paragraphText, // New parameter for paragraph text
    double imageWidth = 130,
    double imageHeight = 130,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
      child: Container(
        height: 200,
        width: screenWidth - 50,
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Text and Paragraph Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text with different colors
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 20),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: firstText,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:
                                firstTextColor, // Custom color for the first part
                          ),
                        ),
                        TextSpan(
                          text: ' $secondText',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:
                                secondTextColor, // Custom color for the second part
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Spacing between text and divider
                // Divider
                const Divider(
                  color: Colors.grey, // Divider color
                  thickness: 1, // Divider thickness
                ),
                const SizedBox(
                  height: 10,
                ), // Spacing between divider and paragraph
                // Paragraph Text
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: SizedBox(
                    width: 180,
                    child: Text(
                      paragraphText, // Display the paragraph text
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ), // Spacing between paragraph and child
                // Additional child content
                child,
              ],
            ),

            // Image positioned at the bottom-right corner
            Positioned(
              bottom: 0, // Align to the bottom
              right: -10, // Align to the right
              child: Image.asset(
                imagePath, // Custom image path
                width: imageWidth, // Custom image width
                height: imageHeight, // Custom image height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
