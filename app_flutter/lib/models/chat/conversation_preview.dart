class ConversationPreview {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final String lastMessageText;

  ConversationPreview({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.lastMessageText,
  });

  factory ConversationPreview.fromJson(Map<String, dynamic> json) {
    final other = (json['otherUser'] as Map<String, dynamic>? ?? {});

    return ConversationPreview(
      id: (json['_id'] ?? '').toString(),
      otherUserId: (other['_id'] ?? '').toString(),
      otherUserName: (other['fullName'] ?? 'User').toString(),
      otherUserAvatar: (other['avatar'] ?? '').toString(),
      lastMessageText: (json['lastMessageText'] ?? '').toString(),
    );
  }
}
