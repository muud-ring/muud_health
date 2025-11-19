// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ IMPORTANT:
  // - iOS Simulator: http://localhost:5000
  // - Android Emulator: http://10.0.2.2:5000
  // - Physical device: http://YOUR_COMPUTER_IP:5000
  static const String baseUrl = 'http://localhost:4000';

  // LOGIN
  static Future<Map<String, dynamic>> loginUser(
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/login');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      // Debug logs
      print('Login status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server returned non-JSON response',
        };
      }

      if (response.statusCode == 200) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed (${response.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server. Check your internet / baseUrl.',
      };
    } on HttpException {
      return {'success': false, 'message': 'HTTP error during login.'};
    } on FormatException {
      return {'success': false, 'message': 'Bad response format from server.'};
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Server too slow or unreachable.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // SIGNUP
  static Future<Map<String, dynamic>> signupUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/auth/signup');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Signup status code: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server returned non-JSON response',
        };
      }

      if (response.statusCode == 201) {
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Signup failed (${response.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server. Check your internet / baseUrl.',
      };
    } on HttpException {
      return {'success': false, 'message': 'HTTP error during signup.'};
    } on FormatException {
      return {'success': false, 'message': 'Bad response format from server.'};
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Server too slow or unreachable.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }

  // CALL PROTECTED ENDPOINT
  static Future<Map<String, dynamic>> getProtectedData(String token) async {
    try {
      final url = Uri.parse('$baseUrl/api/health/protected');

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      print('Protected status code: ${response.statusCode}');
      print('Protected response body: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Server returned non-JSON response',
        };
      }

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              data['message'] ??
              'Error fetching protected data (${response.statusCode})',
        };
      }
    } on SocketException {
      return {
        'success': false,
        'message': 'Cannot reach server. Check your internet / baseUrl.',
      };
    } on HttpException {
      return {
        'success': false,
        'message': 'HTTP error during protected request.',
      };
    } on FormatException {
      return {'success': false, 'message': 'Bad response format from server.'};
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Request timed out. Server too slow or unreachable.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Unexpected error: $e'};
    }
  }
}
