import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class HomeTab extends StatelessWidget {
  final String fullName;
  const HomeTab({super.key, required this.fullName});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Text(
        "Good Morning $fullName!",
        style: const TextStyle(
          color: kPrimaryPurple,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
