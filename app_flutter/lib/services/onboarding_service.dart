// lib/services/onboarding_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import 'token_storage.dart';

class OnboardingService {
  /// Generic helper for updating onboarding fields on the backend.
  ///
  /// Backend endpoint: PUT /api/profile/onboarding
  ///
  /// Example:
  ///   OnboardingService.updateOnboarding({'focus': 'Self-improvement'});
  ///   OnboardingService.updateOnboarding({'activities': ['Meditation']});
  ///   OnboardingService.updateOnboarding({'notificationsEnabled': true});
  ///   OnboardingService.updateOnboarding({'supportOptions': ['navigate_emotions']});
  ///   OnboardingService.updateOnboarding({'initialMood': 'happy'});
  ///   OnboardingService.updateOnboarding({'preparingChoice': 'prepare_sessions'});
  static Future<void> updateOnboarding(Map<String, dynamic> data) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      throw Exception('No auth token found');
    }

    final uri = Uri.parse('${ApiService.baseUrl}/api/profile/onboarding');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update onboarding (status ${response.statusCode}): ${response.body}',
      );
    }
  }
}
