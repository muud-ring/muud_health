import 'package:shared_preferences/shared_preferences.dart';

class OnboardingStorage {
  static const _keyHasCompleted = 'has_completed_onboarding';

  static Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasCompleted) ?? false;
  }

  static Future<void> setCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasCompleted, value);
  }
}
