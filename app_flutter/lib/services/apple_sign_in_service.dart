// lib/services/apple_sign_in_service.dart

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleSignInService {
  static Future<AuthorizationCredentialAppleID?> signIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return credential;
    } catch (e) {
      debugPrint('Apple Sign-In error: $e');
      return null;
    }
  }
}
