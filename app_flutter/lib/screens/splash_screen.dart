import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../services/onboarding_storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart'; // you'll add this next

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    // Small delay if you want a splash effect
    await Future.delayed(const Duration(milliseconds: 800));

    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
      // Not logged in at all
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Logged in → check onboarding status
    final hasOnboarded = await OnboardingStorage.hasCompleted();
    if (!mounted) return;

    if (hasOnboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // simple splash, you can keep your existing logo UI
    return const Scaffold(
      body: Center(
        child: Text(
          'MUUD Health',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
