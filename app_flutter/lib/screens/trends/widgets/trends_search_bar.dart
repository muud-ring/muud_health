// lib/screens/trends/widgets/trends_search_bar.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';

class TrendsSearchBar extends StatelessWidget {
  const TrendsSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: const TextStyle(color: kSubheadingColor),
        prefixIcon: const Icon(Icons.search, color: kPrimaryPurple),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: kPrimaryPurple.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          borderSide: BorderSide(color: kPrimaryPurple, width: 1.4),
        ),
      ),
    );
  }
}
