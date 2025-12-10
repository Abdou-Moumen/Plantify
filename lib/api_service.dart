import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant/config.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  static Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/api/predict-disease/'),
      );

      // Add headers
      request.headers['Authorization'] = 'Token $token';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send the request with timeout
      var response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
            'Request timed out. Please try again with a different image.',
          );
        },
      );

      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseJson = json.decode(responseData);

        // Add confidence if not present in the response
        if (!responseJson.containsKey('confidence')) {
          responseJson['confidence'] = 1.0;
        }

        // Set is_reliable based on confidence level
        // If confidence is less than 0.5 (50%), mark as not reliable
        responseJson['is_reliable'] = responseJson['confidence'] >= 0.5;

        return responseJson;
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else if (response.statusCode == 500) {
        // Handle 500 error specifically
        throw Exception(
          'Please upload a clear plant image. The server could not process the current image.',
        );
      } else {
        throw Exception(
          'Please upload a plant image. The server returned: ${response.statusCode}',
        );
      }
    } catch (e) {
      // If the error is not already an Exception, wrap it
      if (e is! Exception) {
        throw Exception(
          'Please upload a valid plant image for identification.',
        );
      }
      rethrow; // Rethrow the existing exception
    }
  }

  static Future<Map<String, dynamic>> getDiseaseDetails(int diseaseId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/api/get-disease/$diseaseId/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed - please login again');
      } else {
        throw Exception(
          'Failed to load disease details: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error loading disease details: $e');
    }
  }
}
