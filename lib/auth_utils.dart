import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:plant/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_token');
}

Future<String?> getUserFullName() async {
  final token = await getToken();
  if (token == null) return null;

  final response = await http.get(
    Uri.parse('${Config.baseUrl}/api/profile/'),
    headers: {
      'Authorization': 'Token $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['first_name'] ?? 'Unknown User';
  }
  return 'Unknown User';
}
