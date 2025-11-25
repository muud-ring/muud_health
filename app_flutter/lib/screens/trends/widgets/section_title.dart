// lib/screens/trends/widgets/section_title.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showSeeAll;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.showSeeAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(color: kSubheadingColor, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        if (showSeeAll)
          Text(
            'See all',
            style: TextStyle(
              color: kPrimaryPurple.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
