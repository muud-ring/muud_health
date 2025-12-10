// lib/services/user_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const _keyFullName = 'user_full_name';

  static Future<void> saveFullName(String fullName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFullName, fullName);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyFullName);
  }
}
