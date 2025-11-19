// lib/services/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // Create storage instance
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _keyToken = 'auth_token';

  // Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Clear token (logout)
  static Future<void> clearToken() async {
    await _storage.delete(key: _keyToken);
  }
}
