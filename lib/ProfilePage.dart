import 'package:flutter/material.dart';
import 'package:plant/custom_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart';
import 'config.dart';
import 'package:plant/profile_model.dart';
import 'package:plant/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    _profile = await ProfileService.getProfile();
    setState(() => _isLoading = false);
  }

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    final success = await ProfileService.updateProfile(data);
    if (success) {
      await showCustomDialog(
        context: context,
        message: 'Profile updated successfully',
        isError: false,
      );
      await _loadProfile();
    } else {
      await showCustomDialog(
        context: context,
        message: 'Failed to update profile',
        isError: true,
      );
    }
    setState(() => _isLoading = false);
  }

  Future<String?> _showEditDialog(
    BuildContext context,
    String field,
    String? currentValue,
  ) async {
    final controller = TextEditingController(text: currentValue);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Center(
            child: Text(
              'Edit $field',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      await _updateProfile({
        'birth_date': formattedDate,
        'profile': {'birth_date': formattedDate},
      });
    }
  }

  // Logout function
  Future<void> _logout(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          title: Text(
            'Logout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      final token = await getToken();
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No user token found')));
        return;
      }

      try {
        final response = await http.post(
          Uri.parse('${Config.baseUrl}/api/logout/'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode == 200) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_token');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text('Failed to load profile')),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF3F5F7),
      body: Column(
        children: [
          // Top container with profile picture
          Stack(
            children: [
              // White container at top
              Container(
                width: screenWidth,
                height: 180,
                decoration: BoxDecoration(color: Colors.white),
              ),
              // Back Arrow
              Positioned(
                left: 16,
                top: 50,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // Profile Picture
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
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
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
          // Profile Information section
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: ListView(
                    children: [
                      // Email in green container
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF517159),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            _profile!.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // First Name
                      _buildProfileItem(
                        context,
                        icon: Icons.person_outline,
                        title: _profile!.firstName ?? 'No name',
                        onTap: () async {
                          final newName = await _showEditDialog(
                            context,
                            'First Name',
                            _profile!.firstName,
                          );
                          if (newName != null &&
                              newName != _profile!.firstName) {
                            await _updateProfile({'first_name': newName});
                          }
                        },
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.phone_android_outlined,
                        title: _profile!.phoneNumber ?? 'No phone',
                        onTap: () async {
                          final newPhone = await _showEditDialog(
                            context,
                            'Phone',
                            _profile!.phoneNumber,
                          );
                          if (newPhone != null &&
                              newPhone != _profile!.phoneNumber) {
                            await _updateProfile({
                              'phone_number': newPhone,
                              'profile': {'phone_number': newPhone},
                            });
                          }
                        },
                      ),
                      _buildProfileItem(
                        context,
                        icon: Icons.work_outline,
                        title: _profile!.speciality ?? 'No speciality',
                        onTap: () async {
                          final newSpeciality = await _showEditDialog(
                            context,
                            'Speciality',
                            _profile!.speciality,
                          );
                          if (newSpeciality != null &&
                              newSpeciality != _profile!.speciality) {
                            await _updateProfile({
                              'speciality': newSpeciality,
                              'profile': {'speciality': newSpeciality},
                            });
                          }
                        },
                      ),

                      // Birth Date - Added this field
                      _buildProfileItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: _profile!.birthDate ?? 'No birth date',
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            final formattedDate =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            if (formattedDate != _profile!.birthDate) {
                              await _updateProfile({
                                'birth_date': formattedDate,
                                'profile': {'birth_date': formattedDate},
                              });
                            }
                          }
                        },
                      ),

                      _buildProfileItem(
                        context,
                        icon: Icons.place_outlined,
                        title: _profile!.birthPlace ?? 'No birth place',
                        onTap: () async {
                          final newPlace = await _showEditDialog(
                            context,
                            'Birth Place',
                            _profile!.birthPlace,
                          );
                          if (newPlace != null &&
                              newPlace != _profile!.birthPlace) {
                            await _updateProfile({
                              'birth_place': newPlace,
                              'profile': {'birth_place': newPlace},
                            });
                          }
                        },
                      ),
                      // Logout option
                      _buildProfileItem(
                        context,
                        icon: Icons.logout_outlined,
                        title: 'Logout',
                        onTap: () {
                          _logout(context);
                        },
                      ),
                      SizedBox(height: 30),
                    ],
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
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: DecorationImage(
                          image: AssetImage('assets/images/WelcomeImage.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build profile items
  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: ListTile(
          leading: Icon(icon, color: Color(0xFF517159)),
          title: Text(title, style: TextStyle(fontSize: 16)),
          trailing: Icon(
            Icons.edit_note_outlined,
            size: 20,
            color: Color(0xFF517159),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
