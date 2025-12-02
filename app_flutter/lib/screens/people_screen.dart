// lib/screens/people_screen.dart

import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kLightPurple = Color(0xFFDAC9E8);

class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // INNER CIRCLE
          // ----------------------------------------------------
          _sectionHeader("Inner Circle", onSeeAll: () {}),
          const SizedBox(height: 20),
          _EmptySectionCard(
            iconPath: "assets/images/people/diversity_2.png",
            title: "No Inner Circle",
            subtitle: "Your inner circles will show up here.",
            buttonLabel: "Add friends",
            onPressed: () {},
          ),

          const SizedBox(height: 32),

          // ----------------------------------------------------
          // CONNECTIONS
          // ----------------------------------------------------
          _sectionHeader("Connections", onSeeAll: () {}),
          const SizedBox(height: 20),
          _EmptySectionCard(
            iconPath: "assets/images/people/group_add.png",
            title: "No Connections",
            subtitle: "Your connections will show up here.",
            buttonLabel: "Add friends",
            onPressed: () {},
          ),

          const SizedBox(height: 32),

          // ----------------------------------------------------
          // SUGGESTED FRIENDS
          // ----------------------------------------------------
          _sectionHeader("Suggested Friends", onSeeAll: () {}),
          const SizedBox(height: 16),
          const _SuggestedFriendsRow(),
        ],
      ),
    );
  }
}

// ---------- SECTION HEADER ----------
Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: kPrimaryPurple,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      GestureDetector(
        onTap: onSeeAll,
        child: const Text(
          "See All",
          style: TextStyle(
            color: kPrimaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// ---------- EMPTY STATE CARD ----------
class _EmptySectionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _EmptySectionCard({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 56, color: kLightPurple),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryPurple,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- SUGGESTED FRIENDS ROW (DUMMY DATA FOR NOW) ----------
class _SuggestedFriendsRow extends StatelessWidget {
  const _SuggestedFriendsRow();

  @override
  Widget build(BuildContext context) {
    // dummy data – replace later with backend data
    final friends = [
      {"name": "James Carter", "handle": "@james"},
      {"name": "Henry C.", "handle": "@henry"},
      {"name": "Sean K.", "handle": "@seank"},
      {"name": "Arya Singh", "handle": "@arya"},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: friends.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final f = friends[index];
          return Column(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: kLightPurple,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                f['name']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                f['handle']!,
                style: const TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ],
          );
        },
      ),
    );
  }
}
