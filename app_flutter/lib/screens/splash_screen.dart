import 'package:flutter/material.dart';
import '../services/token_storage.dart';
import '../services/onboarding_storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_flow_screen.dart';

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
    // Small delay for splash effect
    await Future.delayed(const Duration(milliseconds: 800));

    final token = await TokenStorage.getToken();
    if (!mounted) return;

    if (token == null) {
      // Not logged in
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
        MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Figma-style gradient + centered MUUD logo
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              // TODO: replace these with your exact Figma hex values
              Color(0xFF9C4CE4), // lighter purple (top-left)
              Color(0xFF4B1573), // darker purple (bottom-right)
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/logos/muud_logo.png',
            width: 180, // tweak to match your Figma size
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
