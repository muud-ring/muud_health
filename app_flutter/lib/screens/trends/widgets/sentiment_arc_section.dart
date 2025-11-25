// lib/screens/trends/widgets/sentiment_arc_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class SentimentArcSection extends StatelessWidget {
  final SentimentArc sentimentArc;

  const SentimentArcSection({super.key, required this.sentimentArc});

  @override
  Widget build(BuildContext context) {
    final scores = sentimentArc.days.map((d) => d.score).toList();
    final note = sentimentArc.note.isEmpty
        ? 'Your mood timeline will update as you log more.'
        : sentimentArc.note;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'MUUD Timeline',
          subtitle: 'How your mood changed this week',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: kPrimaryPurple.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (scores.isEmpty)
                const Text(
                  'No mood data yet. Start logging your MUUD to see trends here.',
                  style: TextStyle(color: kSubheadingColor, fontSize: 12),
                )
              else
                Row(
                  children: scores
                      .map(
                        (s) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.lerp(
                                Colors.pink.shade50,
                                kPrimaryPurple,
                                s.clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 12),
              Text(
                note,
                style: const TextStyle(color: kSubheadingColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
