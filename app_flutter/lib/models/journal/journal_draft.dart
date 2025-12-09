// lib/models/journal/journal_draft.dart

class JournalDraft {
  final String imagePath;
  final String caption;
  final String visibility;
  final DateTime createdAt;

  const JournalDraft({
    required this.imagePath,
    required this.caption,
    required this.visibility,
    required this.createdAt,
  });
}
