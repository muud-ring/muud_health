// lib/widgets/home/journal_entry_card.dart

import 'package:flutter/material.dart';
import 'package:app_flutter/models/journal/journal_entry.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    // For now, imageUrl will be empty until we hook up S3.
    // So we show a simple placeholder box instead of an image.
    final hasImage = entry.imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 64,
              height: 64,
              child: hasImage
                  ? Image.network(entry.imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: const Color(0xFFE3D6FF),
                      child: const Icon(
                        Icons.photo_outlined,
                        color: kPrimaryPurple,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.caption.isNotEmpty
                      ? entry.caption
                      : 'New journal entry',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.visibility,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
