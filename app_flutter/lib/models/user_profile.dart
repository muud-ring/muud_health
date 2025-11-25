// lib/models/user_profile.dart

class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String bio;
  final String location;
  final String mood;
  final String avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.bio,
    required this.location,
    required this.mood,
    required this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      mood: json['mood'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'username': username,
      'bio': bio,
      'location': location,
      'phone': phone,
      'mood': mood,
      'avatarUrl': avatarUrl,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? bio,
    String? location,
    String? mood,
    String? avatarUrl,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      mood: mood ?? this.mood,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
