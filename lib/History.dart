import 'package:plant/LoginPage.dart';
import 'package:plant/custom_dialog.dart';
import 'package:plant/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plant/auth_utils.dart';
import 'dart:convert';
import 'config.dart';
import 'PlantDetail.dart';
import 'package:plant/Home.dart';
import 'package:plant/ProfilePage.dart';
import 'package:plant/SettingsPage.dart';
import 'package:plant/Chatpage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  int _selectedIndex = 3; // Set to 3 to activate the community icon
  List<Map<String, dynamic>> historyItems = []; // Initialize an empty list

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _gridAnimation;
  late Animation<double> _navBarAnimation;

  @override
  void initState() {
    super.initState();
    fetchUserFullName();

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

    _searchBarAnimation = Tween<double>(begin: -30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _gridAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    _navBarAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.6, 0.9, curve: Curves.easeOutQuint),
      ),
    );

    // Start the animation
    _animationController.forward();

    // Fetch plant diseases when the widget is initialized
    fetchPlantDiseases();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getShortenedFirstName(String fullName) {
    if (fullName.isEmpty) return 'Unknown';
    String firstName = fullName.split(' ').first;
    return firstName.length > 15 ? firstName.substring(0, 10) : firstName;
  }

  String userFullName = 'Loading...';

  Future<void> fetchUserFullName() async {
    String? fullName = await getUserFullName();
    setState(() {
      userFullName = fullName ?? 'Unknown User';
    });
  }

  Future<void> fetchPlantDiseases() async {
    final token = await getToken(); // Retrieve token from SharedPreferences

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No user token found')));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/plant-diseases/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Add token in the header
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Parsed data: $data');

        setState(() {
          historyItems =
              data.map<Map<String, dynamic>>((disease) {
                return {
                  'type': 'disease',
                  'id': disease['id'],
                  'plant_name': disease['plant_name'],
                  'plant_definition': disease['plant_definition'],
                  'disease_name': disease['disease_name'],
                  'disease_description': disease['disease_description'],
                  'symptoms': disease['symptoms'],
                  'management': disease['management'],
                  'image': disease['image'],
                };
              }).toList();
        });

        print('History items: $historyItems');
      } else {
        print('Failed to load plant diseases: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plant diseases: $e');
    }
  }

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

  Future<void> _processImage(File imageFile) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      final prediction = await ApiService.predictDisease(imageFile);
      Navigator.pop(context); // Close loading dialog

      // Navigate to PlantDetail with the prediction data
      final result = await Navigator.push(
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

      // Refresh the history list when returning from PlantDetail
      fetchPlantDiseases();

      // Show success message (optional)
      showCustomDialog(
        context: context,
        message: 'Plant disease identified successfully!',
        isError: false,
      );
    } catch (e) {
      Navigator.pop(context); // Ensure loading dialog is closed on error

      // Show error message
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

  // Function to handle item selection
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );

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
      backgroundColor: const Color(0xFFF3F5F7),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // App Bar Section
              Positioned(
                top: screenHeight * 0.08 + _headerAnimation.value,
                left: 35,
                right: 35,
                child: Opacity(
                  opacity: 1 - _headerAnimation.value.abs() / 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hi',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: ' ${_getShortenedFirstName(userFullName)}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF41734E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            ),
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

              // Search Bar
              Positioned(
                top: screenHeight * 0.16 + _searchBarAnimation.value,
                left: 35,
                right: 35,
                child: Opacity(
                  opacity: 1 - _searchBarAnimation.value.abs() / 30,
                  child: _buildSearchBar(),
                ),
              ),

              // History Grid
              Positioned(
                top: screenHeight * 0.22,
                left: 0,
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: Offset(0, _gridAnimation.value),
                  child: Opacity(
                    opacity: 1 - _gridAnimation.value / 50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: _buildHistoryGrid(),
                    ),
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.transparent,
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
                          label: '',
                        );
                      }).toList(),
                  selectedItemColor: const Color(0xFF41734E),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFDAE5DD),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search),
            hintText: 'Search for your plant',
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryGrid() {
    if (historyItems.isEmpty) {
      return const Center(
        child: Text(
          'No diseases found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 0,
        childAspectRatio: 0.68,
      ),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        // Add staggered animation for each card
        final delay = index * 0.1;
        final cardAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              0.4 + delay,
              0.7 + delay,
              curve: Curves.easeOutQuint,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: cardAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, cardAnimation.value),
              child: Opacity(
                opacity: 1 - cardAnimation.value / 50,
                child: _buildDiseaseCard(historyItems[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDiseaseCard(Map<String, dynamic> disease) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Container(
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  height: 110,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFEFEFEF),
                    image: const DecorationImage(
                      image: AssetImage('assets/cards/cardBg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 22,
              right: 0,
              left: 0,
              child: Center(
                child: Image(
                  image: AssetImage('assets/cards/plant.png'),
                  width: 80,
                  height: 80,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease['disease_name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF41734E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Search for your plant!',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PlantDetail(
                            diseaseId: disease['id'],
                            isDefaultDisease: false,
                            predictedClass: '',
                            diseaseDetails: disease,
                          ),
                    ),
                  );

                  // If the result is true (indicating a deletion), refresh the history list
                  if (result == true) {
                    fetchPlantDiseases(); // Refresh the list
                  }
                },
                child: Center(
                  child: Image(
                    image: AssetImage('assets/cards/plus.png'),
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
