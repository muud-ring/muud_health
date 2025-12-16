class Conversation {
  final String id;
  final List<String> participantIds;
  final DateTime? updatedAt;

  Conversation({
    required this.id,
    required this.participantIds,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final participants =
        (json['participants'] ?? json['participantIds'] ?? []) as List<dynamic>;
    return Conversation(
      id: (json['_id'] ?? json['id']).toString(),
      participantIds: participants.map((e) => e.toString()).toList(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
