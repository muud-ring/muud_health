// lib/screens/journal/journal_preview_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:app_flutter/models/journal/journal_draft.dart';
import 'package:app_flutter/services/api_service.dart';
import 'package:app_flutter/services/token_storage.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalPreviewScreen extends StatelessWidget {
  final String imagePath;
  final String caption;
  final String visibility;

  const JournalPreviewScreen({
    super.key,
    required this.imagePath,
    required this.caption,
    required this.visibility,
  });

  Future<void> _sendAndClose(BuildContext context) async {
    // 1) Try to send to backend (fire-and-forget for now)
    try {
      final token = await TokenStorage.getToken();
      if (token != null) {
        await ApiService.createJournal(
          token: token,
          caption: caption,
          visibility: visibility,
          imageUrl: '', // TODO: replace with S3 URL later
          emoji: '', // we can wire actual emoji later
        );
      } else {
        // No token – just log; we still save locally and pop
        debugPrint('No auth token found when creating journal.');
      }
    } catch (e) {
      debugPrint('Error calling createJournal: $e');
      // We won't block the UX on this – still return to Home
    }

    // 2) Continue existing local flow so Home card still works
    final draft = JournalDraft(
      imagePath: imagePath,
      caption: caption,
      visibility: visibility,
      createdAt: DateTime.now(),
    );

    Navigator.pop(context, draft); // back to Edit with draft → then Home
  }

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ----- Top bar -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryPurple,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _sendAndClose(context),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        color: kPrimaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ----- Image preview (top) -----
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(file, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),

            // ----- Caption + visibility -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      caption.isNotEmpty ? caption : '#happy, #ootd, #healing',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3ECFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visibility,
                      style: const TextStyle(
                        fontSize: 12,
                        color: kPrimaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ----- Voice note card (UI only) -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: kPrimaryPurple),
                    const SizedBox(width: 12),
                    const Text(
                      'Voice note',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '00:12',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kPrimaryPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ----- Suggested Journals button -----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  side: const BorderSide(color: kPrimaryPurple, width: 1.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Suggested journals will be implemented later.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Suggested Journals',
                  style: TextStyle(
                    color: kPrimaryPurple,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
