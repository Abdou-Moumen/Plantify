// lib/services/profile_service.dart
import 'package:http/http.dart' as http;
import 'package:plant/config.dart';
import 'package:plant/profile_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<ProfileData?> getProfile() async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return ProfileData.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<bool> updateProfile(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) return false;

    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/api/update-profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode(data),
    );

    return response.statusCode == 200;
  }
}
