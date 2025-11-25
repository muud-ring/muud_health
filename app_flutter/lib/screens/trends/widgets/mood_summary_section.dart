// lib/screens/trends/widgets/mood_summary_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class MoodSummarySection extends StatelessWidget {
  final MoodSummary moodSummary;

  const MoodSummarySection({super.key, required this.moodSummary});

  @override
  Widget build(BuildContext context) {
    final mood = moodSummary.todayMood.isEmpty
        ? 'Neutral'
        : moodSummary.todayMood;
    final emoji = moodSummary.emoji.isEmpty ? '😶' : moodSummary.emoji;
    final note = moodSummary.note.isEmpty
        ? 'Your MUUD summary will show here as you log more.'
        : moodSummary.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Mood Summary',
          subtitle: 'Your MUUD over the last week',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardLavender,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Row(
            children: [
              // Mood Ring – still visual, emoji from backend
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          Colors.yellow.shade300,
                          Colors.orange.shade300,
                          Colors.purple.shade300,
                          Colors.yellow.shade300,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today you feel $mood',
                      style: const TextStyle(
                        color: kPrimaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note,
                      style: const TextStyle(
                        color: kSubheadingColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
