class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawImage = (json['imageUrl'] ?? '').toString();
    return ChatMessage(
      id: (json['_id'] ?? json['id']).toString(),
      conversationId: (json['conversationId'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      imageUrl: rawImage.isEmpty ? null : rawImage,
      createdAt: DateTime.parse(json['createdAt'].toString()),
    );
  }
}
