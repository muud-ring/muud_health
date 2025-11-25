// lib/screens/trends/widgets/daily_snapshot_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class DailySnapshotSection extends StatelessWidget {
  final DailySnapshot snapshot;

  const DailySnapshotSection({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final journals = snapshot.journalsLogged;
    final journeys = snapshot.journeysCompleted;
    final heartRate = snapshot.avgHeartRate;
    final stress = snapshot.stressLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Daily Snapshot'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SnapshotCard(
                title: 'Journals',
                value: journals.toString(),
                subtitle: 'Logged',
                background: kCardLavender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SnapshotCard(
                title: 'Wellness Journey',
                value: journeys.toString(),
                subtitle: 'Completed',
                background: kCardLavender,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SnapshotCard(
                title: 'Heart rate',
                value: heartRate.toString(),
                subtitle: 'Average BPM',
                background: kCardPink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SnapshotCard(
                title: 'Stress level',
                value: stress,
                subtitle: 'Average level',
                background: kCardPeach,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color background;

  const _SnapshotCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryPurple,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: kPrimaryPurple,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: kSubheadingColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
