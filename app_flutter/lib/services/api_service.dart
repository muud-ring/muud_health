// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'package:app_flutter/models/journal/journal_entry.dart';

import 'token_storage.dart';
import '../models/people/person_summary.dart';
import '../models/people/person_profile.dart';
import '../models/chat/conversation.dart';
import '../models/chat/chat_message.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat/conversation_preview.dart';

class ApiService {
  // 🔗 Your Render backend URL (no trailing slash)
  static const String baseUrl = "http://10.0.0.69:4000";

  // For production / Render
  // static const String baseUrl = 'https://muud-health.onrender.com';

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
  // ---------- LOGIN (EMAIL OR PHONE) ----------
  static Future<Map<String, dynamic>> loginUser(
    String identifier,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"emailOrPhone": identifier, "password": password}),
      );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': body['token'],
          'user': body['user'], // 👈 now also returns user
        };
      } else {
        return {'success': false, 'message': body['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
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

  // ---------- GOOGLE OAUTH LOGIN ----------
  static Future<Map<String, dynamic>> googleLogin(String idToken) async {
    final url = Uri.parse('$baseUrl/api/auth/google');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"idToken": idToken}),
      );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "token": body["token"], "user": body["user"]};
      } else {
        return {
          "success": false,
          "message": body["message"] ?? "Google login failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error"};
    }
  }

  // ---------- APPLE SIGN-IN ----------
  static Future<Map<String, dynamic>> appleLogin({
    required String idToken,
    String? fullName,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/apple');

    final body = jsonEncode({
      'idToken': idToken,
      if (fullName != null) 'fullName': fullName,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = _safeJsonDecode(response.body);

    // Debug logs (similar to your SIGNUP logs)
    print('APPLE status: ${response.statusCode}');
    print('APPLE body: ${response.body}');

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Apple Sign-In failed.');
    }
  }

  // ---------- FACEBOOK LOGIN ----------
  static Future<Map<String, dynamic>> facebookLogin(String accessToken) async {
    final url = Uri.parse('$baseUrl/api/auth/facebook');

    final body = jsonEncode({'accessToken': accessToken});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    final data = _safeJsonDecode(response.body);

    // Debug logs
    print('FACEBOOK status: ${response.statusCode}');
    print('FACEBOOK body: ${response.body}');

    if (response.statusCode == 200) {
      return data; // { token, user: {...} }
    } else {
      throw Exception(data['message'] ?? 'Facebook login failed.');
    }
  }

  // ---------- AUTH HEADER (JWT) ----------
  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // =========================
  // PEOPLE
  // =========================

  // GET /api/people
  static Future<List<PersonSummary>> fetchPeople() async {
    final url = Uri.parse('$baseUrl/api/people');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    print('PEOPLE status: ${response.statusCode}');
    print('PEOPLE body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('fetchPeople failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    // supports: [ ... ] OR { people: [ ... ] }
    final list = (decoded is Map<String, dynamic>)
        ? (decoded['people'] ?? [])
        : decoded;

    if (list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => PersonSummary.fromJson(e))
        .toList();
  }

  // GET /api/people/:id
  static Future<PersonProfile> fetchPersonProfile(String id) async {
    final url = Uri.parse('$baseUrl/api/people/$id');
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    print('PEOPLE PROFILE status: ${response.statusCode}');
    print('PEOPLE PROFILE body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('fetchPersonProfile failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    // supports: { person: {...} } OR { user: {...} } OR direct object
    final obj = (decoded is Map<String, dynamic>)
        ? (decoded['person'] ?? decoded['user'] ?? decoded)
        : <String, dynamic>{};

    return PersonProfile.fromJson(obj as Map<String, dynamic>);
  }

  // =========================
  // CHAT
  // =========================

  // POST /api/chats/conversations
  static Future<Conversation> createConversation({
    required String otherUserId,
  }) async {
    final url = Uri.parse('$baseUrl/api/chats/conversations');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'otherUserId': otherUserId}),
    );

    print('CREATE CONVO status: ${response.statusCode}');
    print('CREATE CONVO body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = _safeJsonDecode(response.body);
      throw Exception(body['message'] ?? 'createConversation failed');
    }

    final decoded = jsonDecode(response.body);
    final obj = (decoded is Map<String, dynamic>)
        ? (decoded['conversation'] ?? decoded)
        : <String, dynamic>{};

    return Conversation.fromJson(obj as Map<String, dynamic>);
  }

  // POST /api/chats/messages
  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String text,
    String? imageUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/chats/messages');
    final headers = await _authHeaders();

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'conversationId': conversationId,
        'text': text,
        'imageUrl': imageUrl ?? '',
      }),
    );

    print('SEND MSG status: ${response.statusCode}');
    print('SEND MSG body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = _safeJsonDecode(response.body);
      throw Exception(body['message'] ?? 'sendMessage failed');
    }

    final decoded = jsonDecode(response.body);
    final obj = (decoded is Map<String, dynamic>)
        ? (decoded['message'] ?? decoded)
        : <String, dynamic>{};

    return ChatMessage.fromJson(obj as Map<String, dynamic>);
  }

  // GET /api/chats/conversations/:id/messages
  static Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final url = Uri.parse(
      '$baseUrl/api/chats/conversations/$conversationId/messages',
    );
    final headers = await _authHeaders();

    final response = await http.get(url, headers: headers);

    print('GET MSGS status: ${response.statusCode}');
    print('GET MSGS body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('fetchMessages failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    // supports: { messages: [ ... ] } OR [ ... ]
    final list = (decoded is Map<String, dynamic>)
        ? (decoded['messages'] ?? [])
        : decoded;

    if (list is! List) return [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => ChatMessage.fromJson(e))
        .toList();
  }

  static Future<List<ConversationPreview>> getMyConversations(
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/api/chats/conversations');

    final res = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('GET CONVERSATIONS status: ${res.statusCode}');
    print('GET CONVERSATIONS body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Failed to load conversations: ${res.body}');
    }

    final data = jsonDecode(res.body);
    final list = (data['conversations'] as List<dynamic>? ?? []);

    return list
        .map((e) => ConversationPreview.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
