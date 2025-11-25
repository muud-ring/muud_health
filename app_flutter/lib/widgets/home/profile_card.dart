import 'package:flutter/material.dart';
import 'package:app_flutter/models/user_profile.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const ProfileCard({super.key, required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final String moodText = (profile.mood.isNotEmpty)
        ? profile.mood
        : 'Set your mood';
    final String locationText = (profile.location.isNotEmpty)
        ? profile.location
        : 'Add your location';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF6ECFF), // light lavender top
            Colors.white, // fades to white bottom
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with "Edit" on right
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: kPrimaryPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Column(
            children: [
              // Avatar with purple ring
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPrimaryPurple, Color(0xFFB76EFB)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundImage:
                      profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child:
                      (profile.avatarUrl == null || profile.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              // Mood pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: kPrimaryPurple, width: 1.5),
                  color: Colors.white.withOpacity(0.95),
                ),
                child: Text(
                  moodText,
                  style: const TextStyle(
                    color: kPrimaryPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Name
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 6),

              // Location
              Text(
                locationText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.55),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
