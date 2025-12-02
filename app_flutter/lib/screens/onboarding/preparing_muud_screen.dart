import 'package:flutter/material.dart';

class PreparingMuudScreen extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PreparingMuudScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "Just a moment while we get MUUD ready for you…",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            "Thank you for your patience :) We’re here to help you feel better.",
          ),
          const SizedBox(height: 24),
          // TODO: selectable items with checkmarks
          const Text('• Customize journal and journey'),
          const Text('• Prepare your first wellness sessions'),
          const Text('• Creating your optimal plan to enhance your mood'),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: const Text('Continue'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onSkip,
              child: const Text('Skip setup'),
            ),
          ),
        ],
      ),
    );
  }
}
