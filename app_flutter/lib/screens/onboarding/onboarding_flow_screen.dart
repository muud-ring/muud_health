import 'package:flutter/material.dart';

import '../../services/onboarding_storage.dart';
import '../home_screen.dart';

// Onboarding screens
import 'welcome_screen.dart';
import 'welcome_screen02.dart';
import 'welcome_screen03.dart';
import 'welcome_screen04.dart';
import 'welcome_screen05.dart';
import 'welcome_screen06.dart';
import 'welcome_screen07.dart';
import 'welcome_screen08.dart'; // 👈 NEW
import 'intro_muud_screen.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  int _currentStep = 0;
  late final List<Widget> _steps;

  @override
  void initState() {
    super.initState();

    _steps = [
      WelcomeScreen(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen02(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen03(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen04(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen05(onAllow: _next, onDeny: _next),
      WelcomeScreen06(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen07(onContinue: _next, onSkip: _skipAll),
      WelcomeScreen08(onContinue: _next, onSkip: _skipAll),

      // Final intro → home
      IntroMuudScreen(onNext: _goToHome),
    ];
  }

  void _next() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _goToHome();
    }
  }

  void _skipAll() {
    _goToHome();
  }

  Future<void> _goToHome() async {
    await OnboardingStorage.setCompleted(true);

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _steps[_currentStep]));
  }
}
