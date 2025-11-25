// lib/screens/trends/widgets/top_tags_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';

class TopTagsSection extends StatelessWidget {
  final List<String> tags;

  const TopTagsSection({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SectionTitle(title: 'Top Tags This Week'),
          SizedBox(height: 8),
          Text(
            'Start journaling to see your top emotional tags here.',
            style: TextStyle(color: kSubheadingColor, fontSize: 12),
          ),
        ],
      );
    }

    // Assign font sizes based on index (bigger = more frequent)
    final baseSizes = [26.0, 22.0, 18.0, 16.0];
    final words = tags.asMap().entries.map((entry) {
      final index = entry.key;
      final tag = entry.value;
      final size = index < baseSizes.length ? baseSizes[index] : 14.0;
      return _TagWord(tag, size);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Top Tags This Week'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: kCardLavender,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 4,
            children: words
                .map(
                  (t) => Text(
                    t.word,
                    style: TextStyle(
                      color: kPrimaryPurple,
                      fontSize: t.size,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _TagWord {
  final String word;
  final double size;
  _TagWord(this.word, this.size);
}
