// lib/screens/trends/widgets/streaks_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class StreaksSection extends StatelessWidget {
  final Streaks streaks;

  const StreaksSection({super.key, required this.streaks});

  @override
  Widget build(BuildContext context) {
    final current = streaks.currentStreak;
    final longest = streaks.longestStreak;

    // For now, keep a simple static week row – later we can map calendar days
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Streak & Milestones',
          subtitle: 'Logging consistency this month',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardLavender,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Streak: $current days in a row 🎉',
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Longest streak: $longest days',
                style: const TextStyle(color: kSubheadingColor, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days
                    .map(
                      (d) => Column(
                        children: [
                          Text(
                            d,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kSubheadingColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: kPrimaryPurple,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: kPrimaryPurple.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              const Text(
                'Keep going! You’re close to your longest streak.',
                style: TextStyle(color: kSubheadingColor, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
