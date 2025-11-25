// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../services/onboarding_storage.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  Future<void> _finishOnboarding(BuildContext context) async {
    await OnboardingStorage.setCompleted(true);

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TEMP UI – just a button. Later we’ll replace with full Figma onboarding.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ElevatedButton(
            onPressed: () => _finishOnboarding(context),
            child: const Text('Finish onboarding'),
          ),
        ),
      ),
    );
  }
}
