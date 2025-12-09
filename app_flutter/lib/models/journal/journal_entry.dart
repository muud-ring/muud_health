// lib/models/journal/journal_entry.dart

class JournalEntry {
  final String id;
  final String imageUrl;
  final String caption;
  final String visibility;
  final String emoji;
  final DateTime createdAt;
  final DateTime? updatedAt;

  JournalEntry({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.visibility,
    required this.emoji,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['_id']?.toString() ?? '',
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'] ?? '',
      visibility: json['visibility'] ?? 'Public',
      emoji: json['emoji'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }
}
