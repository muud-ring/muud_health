class PersonSummary {
  final String id;
  final String name;
  final String? username;
  final String? avatarUrl;

  PersonSummary({
    required this.id,
    required this.name,
    this.username,
    this.avatarUrl,
  });

  factory PersonSummary.fromJson(Map<String, dynamic> json) {
    return PersonSummary(
      id: (json['_id'] ?? json['id']).toString(),
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
      username: json['username']?.toString(),
      avatarUrl: (json['avatarUrl'] ?? json['profileImageUrl'])?.toString(),
    );
  }
}
