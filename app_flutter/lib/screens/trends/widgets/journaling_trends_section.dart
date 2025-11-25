// lib/screens/trends/widgets/journaling_trends_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class JournalingTrendsSection extends StatelessWidget {
  final JournalingTrends trends;

  const JournalingTrendsSection({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
    final days = trends.daysJournaling;
    final change = trends.toneChangePercent;
    final tags = trends.topTags;

    final toneText = change == 0
        ? 'Your journal tone will update as you write more.'
        : 'Journal tone is $change% more positive compared to last month.';

    final tagsText = tags.isEmpty
        ? 'Start journaling to see your top emotional tags.'
        : 'Top tags: ${tags.join(', ')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Journaling Trends'),
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
                '$days Days Journaling',
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                toneText,
                style: const TextStyle(color: kSubheadingColor, fontSize: 12),
              ),
              const SizedBox(height: 10),
              Text(
                tagsText,
                style: const TextStyle(color: kPrimaryPurple, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
