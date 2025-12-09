// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'package:app_flutter/models/journal/journal_entry.dart';

class ApiService {
  // 🔗 Your Render backend URL (no trailing slash)
  static const String baseUrl = 'https://muud-health.onrender.com';

  // ---------- Helper to safely decode JSON ----------
  static Map<String, dynamic> _safeJsonDecode(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else {
        return {};
      }
    } on FormatException catch (e) {
      print('JSON decode error: $e');
      print('Raw body: $body');
      return {};
    }
  }

  // ---------- LOGIN ----------
  static Future<Map<String, dynamic>> loginUser(
    String identifier,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'identifier': identifier, 'password': password}),
    );

    print('LOGIN status: ${response.statusCode}');
    print('LOGIN body: ${response.body}');

    final data = _safeJsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'token': data['token'], 'data': data};
    } else {
      return {
        'success': false,
        'message':
            data['message'] ?? 'Login failed (code ${response.statusCode}).',
      };
    }
  }

  // ---------- SIGN UP ----------
  static Future<Map<String, dynamic>> signupUser({
    required String mobileOrEmail,
    required String fullName,
    required String username,
    required String password,
    required String dateOfBirth,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/signup');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'mobileOrEmail': mobileOrEmail,
        'fullName': fullName,
        'username': username,
        'password': password,
        'dateOfBirth': dateOfBirth,
      }),
    );

    print('SIGNUP status: ${response.statusCode}');
    print('SIGNUP body: ${response.body}');

    final data = _safeJsonDecode(response.body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {'success': true, 'token': data['token'], 'data': data};
    } else {
      return {
        'success': false,
        'message':
            data['message'] ?? 'Signup failed (code ${response.statusCode}).',
      };
    }
  }

  // ---------- PROTECTED DATA ----------
  static Future<Map<String, dynamic>> getProtectedData(String token) async {
    final url = Uri.parse('$baseUrl/api/health/protected');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PROTECTED status: ${response.statusCode}');
    print('PROTECTED body: ${response.body}');

    final data = _safeJsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message':
            data['message'] ??
            'Failed to load protected data (code ${response.statusCode}).',
      };
    }
  }

  // ---------- PROFILE: GET ----------
  static Future<UserProfile?> getMyProfile(String token) async {
    final url = Uri.parse('$baseUrl/api/profile/me');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PROFILE GET status: ${response.statusCode}');
    print('PROFILE GET body: ${response.body}');

    final data = _safeJsonDecode(response.body);

    if (response.statusCode == 200 && data['user'] != null) {
      return UserProfile.fromJson(data['user']);
    } else {
      return null;
    }
  }

  // ---------- PROFILE: UPDATE ----------
  static Future<UserProfile?> updateMyProfile(
    String token,
    UserProfile profile,
  ) async {
    final url = Uri.parse('$baseUrl/api/profile/me');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profile.toUpdateJson()),
    );

    print('PROFILE PATCH status: ${response.statusCode}');
    print('PROFILE PATCH body: ${response.body}');

    final data = _safeJsonDecode(response.body);

    if (response.statusCode == 200 && data['user'] != null) {
      return UserProfile.fromJson(data['user']);
    } else {
      return null;
    }
  }

  // ---------- TRENDS DASHBOARD ----------
  static Future<Map<String, dynamic>?> getTrendsDashboard(String token) async {
    final url = Uri.parse('$baseUrl/api/trends/dashboard');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('TRENDS status: ${response.statusCode}');
      print('TRENDS body: ${response.body}');

      if (response.statusCode == 200) {
        return _safeJsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error in getTrendsDashboard: $e');
      return null;
    }
  }

  // ---------- JOURNAL: CREATE ----------
  static Future<JournalEntry?> createJournal({
    required String token,
    required String caption,
    required String visibility,
    String? imageUrl,
    String? emoji,
  }) async {
    final url = Uri.parse('$baseUrl/api/journals');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'caption': caption,
          'visibility': visibility,
          'imageUrl': imageUrl ?? '',
          'emoji': emoji ?? '',
        }),
      );

      print('CREATE JOURNAL status: ${response.statusCode}');
      print('CREATE JOURNAL body: ${response.body}');

      if (response.statusCode == 201) {
        final data = _safeJsonDecode(response.body);
        return JournalEntry.fromJson(data);
      } else {
        print(
          'createJournal error: status=${response.statusCode}, body=${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('createJournal exception: $e');
      return null;
    }
  }

  // ---------- JOURNAL: GET MY JOURNALS ----------
  static Future<List<JournalEntry>> getMyJournals(String token) async {
    final url = Uri.parse('$baseUrl/api/journals/me');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('GET MY JOURNALS status: ${response.statusCode}');
      print('GET MY JOURNALS body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Case 1: backend returns array
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map((e) => JournalEntry.fromJson(e))
              .toList();
        }

        // Case 2: backend returns object { journals: [] }
        if (decoded is Map<String, dynamic>) {
          final list = decoded['journals'];
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => JournalEntry.fromJson(e))
                .toList();
          }
        }

        print('getMyJournals: unexpected JSON shape');
        return [];
      } else {
        print(
          'getMyJournals error: status=${response.statusCode}, body=${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('getMyJournals exception: $e');
      return [];
    }
  }
}
