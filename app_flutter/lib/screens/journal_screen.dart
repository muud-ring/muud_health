// lib/screens/journal_screen.dart

import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Journal / Add Entry',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kPrimaryPurple,
        ),
      ),
    );
  }
}
