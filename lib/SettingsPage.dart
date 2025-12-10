import 'package:flutter/material.dart';
import 'package:plant/History.dart';
import 'package:plant/PrivacyPolicyPage.dart';
import 'package:plant/ReminderPage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top Gradient Container
          Stack(
            children: [
              // Green Gradient Container (First in the Stack)
              Container(
                width: screenWidth,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B6546), Color(0xFF3F704C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(
                      40,
                    ), // Radius for bottom-left corner
                    bottomRight: Radius.circular(
                      40,
                    ), // Radius for bottom-right corner
                  ),
                ),
              ),
              // Back Arrow (Second in the Stack)
              Positioned(
                left: 16,
                top: 40,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Settings Text (Third in the Stack)
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Profile Picture (Fourth in the Stack - Will appear on top)
              Positioned(
                top: 180 - 60,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRect(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Make the container circular
                        border: Border.all(
                          color: Colors.white, // White stroke color
                          width: 3, // Stroke width
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/WelcomeImage.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // ListView for Settings Items
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: .0),
                  child: Container(
                    child: ListView(
                      children: [
                        SizedBox(
                          height: 30,
                        ), // Add space for the bottom half of the profile picture
                        _buildSectionHeader('Contact'),
                        _buildSettingItem(
                          context,
                          icon: Icons.email_outlined,
                          title: 'Abderrah@gmail.com',
                          onTap: () {
                            // Navigate to notifications settings
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.phone_android_outlined,
                          title: '0775916837',
                          onTap: () {
                            // Navigate to theme settings
                          },
                        ),
                        _buildSectionHeader('Preferences'),
                        _buildSettingItem(
                          context,
                          icon: Icons.language,
                          title: 'Language',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  title: Text(
                                    'Select Language',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: Text('English'),
                                        onTap: () {
                                          // Set app language to English
                                          Navigator.pop(context);
                                          // Implement logic to follow system language or set to English
                                        },
                                      ),
                                      ListTile(
                                        title: Text('French'),
                                        onTap: () {
                                          // Set app language to French
                                          Navigator.pop(context);
                                          // Implement logic to follow system language or set to French
                                        },
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Information',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacyPolicyPage(),
                              ),
                            );
                          },
                        ),
                        // _buildSettingItem(
                        //   context,
                        //   icon: Icons.calendar_month_outlined,
                        //   title: 'Reminders',
                        //   onTap: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => Reminderpage(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        _buildSettingItem(
                          context,
                          icon: Icons.history_outlined,
                          title: 'History',
                          onTap: () {
                            // Navigate to the RegisterPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => History(),
                              ),
                            );
                          },
                        ),

                        // New About Us section
                        _buildSectionHeader('About Us'),
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'Our Mission',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(
                                    'Our Mission',
                                    style: TextStyle(
                                      color: Color(0xFF517159),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Our mission is to connect people with nature by making plant care accessible and enjoyable for everyone. We believe that nurturing plants can improve wellbeing and create healthier living spaces.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Color(0xFF517159),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.people_outline,
                          title: 'Our Team',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(
                                    'Our Team',
                                    style: TextStyle(
                                      color: Color(0xFF517159),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'We are a passionate team of botanists, designers, and developers who love plants and technology. Together, we\'ve created this app to share our knowledge and help you build your own green sanctuary.',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Color(0xFF517159),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        _buildSettingItem(
                          context,
                          icon: Icons.contact_support_outlined,
                          title: 'Contact Us',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  title: Text(
                                    'Contact Us',
                                    style: TextStyle(
                                      color: Color(0xFF517159),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: Container(
                                    width: double.maxFinite,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Have questions or feedback?\nWe\'d love to hear from you!',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 20),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFECF4ED),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF517159),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.email,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  'support@plant.com',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFECF4ED),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF517159),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.phone,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                '+213 775 916 837',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFECF4ED),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF517159),
                                                  shape: BoxShape.circle,
                                                ),
                                                padding: EdgeInsets.all(8),
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  '123 Green Street,\nPlantville, Earth 12345',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    Center(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF517159),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(height: 30),
                        // _buildSettingItem(
                        //   context,
                        //   icon: Icons.logout,
                        //   title: 'Logout',
                        //   onTap: () {
                        //     // Handle logout
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
                // Bottom Half of the Profile Picture
                Positioned(
                  top: -60,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, // Make the container circular
                        border: Border.all(
                          color: Colors.white, // White stroke color
                          width: 3, // Stroke width
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/images/WelcomeImage.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 60,
                //   left: 0,
                //   right: 0,
                //   child: Center(
                //     child: Text(
                //       'Abdou Moumen',
                //       style: TextStyle(
                //         fontSize: 22,
                //         fontWeight: FontWeight.w800,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 229, 237, 231),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF517159)),
          title: Text(title, style: TextStyle(fontSize: 16)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF517159),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
