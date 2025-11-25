// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Explore',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kPrimaryPurple,
        ),
      ),
    );
  }
}
