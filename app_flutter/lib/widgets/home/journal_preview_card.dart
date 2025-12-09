// lib/widgets/home/journal_preview_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_flutter/models/journal/journal_draft.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalPreviewCard extends StatelessWidget {
  final JournalDraft draft;

  const JournalPreviewCard({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final file = File(draft.imagePath);

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
              child: Image.file(file, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.caption.isNotEmpty
                      ? draft.caption
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
                  draft.visibility,
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
