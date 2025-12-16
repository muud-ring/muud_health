class PersonProfile {
  final String id;
  final String name;
  final String? username;
  final String? avatarUrl;
  final String? bio;

  PersonProfile({
    required this.id,
    required this.name,
    this.username,
    this.avatarUrl,
    this.bio,
  });

  factory PersonProfile.fromJson(Map<String, dynamic> json) {
    return PersonProfile(
      id: (json['_id'] ?? json['id']).toString(),
      name: (json['fullName'] ?? json['name'] ?? '').toString(),
      username: json['username']?.toString(),
      avatarUrl: (json['avatarUrl'] ?? json['profileImageUrl'])?.toString(),
      bio: json['bio']?.toString(),
    );
  }
}
