import 'package:flutter/material.dart';

class WelcomeScreen02 extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen02({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  static const Color _primaryPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Back / close arrow
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
            'Hello!\nWelcome to MUUD Health!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: _primaryPurple,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          const Text(
            "Let’s take a few minutes to get you set up. "
            "Ensure you’re in a quiet space and ready for the next steps.",
            style: TextStyle(fontSize: 16, height: 1.4, color: _primaryPurple),
          ),

          const SizedBox(height: 32),

          // Illustration
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/onboarding/onboarding_welcome01.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _primaryPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: const StadiumBorder(),
                foregroundColor: Colors.white, // <-- forces white text/icons
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skip setup button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSkip,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: const StadiumBorder(),
                side: const BorderSide(color: _primaryPurple, width: 1.5),
              ),
              child: const Text(
                'Skip setup',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _primaryPurple,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
