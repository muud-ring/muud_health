import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  static const _primaryPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Back / skip arrow (top-left)
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: _primaryPurple,
            ),
            onPressed: onSkip,
          ),

          const SizedBox(height: 24),

          // Title
          const Text(
            'MUUD Health',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _primaryPurple,
            ),
          ),

          const SizedBox(height: 12),

          // Subtitle
          const Text(
            'Develop healthy habits and\nnurture your mental well-being.',
            style: TextStyle(fontSize: 18, height: 1.4, color: _primaryPurple),
          ),

          const SizedBox(height: 32),

          // Illustration (exported without text & button)
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/onboarding/onboarding_welcome.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // "Next" button – pill shaped like in Figma
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
