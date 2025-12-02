import 'package:flutter/material.dart';

class IntroMuudScreen extends StatelessWidget {
  final VoidCallback onNext;

  const IntroMuudScreen({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            "MUUD Health",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            "Develop healthy habits and nurture your mental well-being.",
          ),
          const Spacer(),
          // TODO: big illustration from Figma
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onNext, child: const Text('Next')),
          ),
        ],
      ),
    );
  }
}
