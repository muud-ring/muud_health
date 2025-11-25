// lib/screens/trends/widgets/wellness_journey_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class WellnessJourneySection extends StatelessWidget {
  final WellnessJourney journey;

  const WellnessJourneySection({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final slices = journey.pie;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Wellness Journey Trends'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(kCardRadius),
            border: Border.all(color: kPrimaryPurple.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              // Simple donut chart style (visual only)
              SizedBox(
                height: 120,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Color(0xFFB39DDB),
                              Color(0xFFF48FB1),
                              Color(0xFFFFCC80),
                              Color(0xFFB39DDB),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Legend using backend slices
              Column(
                children: slices.isEmpty
                    ? const [
                        Text(
                          'Complete wellness activities to see your journey breakdown here.',
                          style: TextStyle(
                            color: kSubheadingColor,
                            fontSize: 12,
                          ),
                        ),
                      ]
                    : slices
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _LegendRow(
                                label: '${s.label} (${s.percent}%)',
                              ),
                            ),
                          )
                          .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;

  const _LegendRow({required this.label});

  @override
  Widget build(BuildContext context) {
    // All same color for now; could map different labels to different colors
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: kPrimaryPurple.withOpacity(0.6),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: kPrimaryPurple),
          ),
        ),
      ],
    );
  }
}
