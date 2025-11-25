// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kTextNeutral = Color(0xFF4A4A5A); // Neutral paragraph color

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: kPrimaryPurple,
          onPressed: () => Navigator.pop(context),
        ),

        title: const Text(
          "Settings",
          style: TextStyle(
            color: kPrimaryPurple,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),

      body: ListView(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kPrimaryPurple,
              ),
            ),
          ),

          _SettingsTile(icon: Icons.person_outline, title: "Security"),
          _Divider(),

          _SettingsTile(icon: Icons.lock_outline, title: "Profile Privacy"),
          _Divider(),

          _SettingsTile(
            icon: Icons.visibility_off_outlined,
            title: "Content Visibility",
          ),
          _Divider(),

          _SettingsTile(icon: Icons.notifications_none, title: "Notifications"),
          _Divider(),

          _SettingsTile(icon: Icons.help_outline, title: "Support"),
          _Divider(),

          _SettingsTile(icon: Icons.shield_outlined, title: "Privacy Policy"),
          _Divider(),

          _SettingsTile(
            icon: Icons.article_outlined,
            title: "Terms & Conditions",
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: kPrimaryPurple, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: kTextNeutral,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: kPrimaryPurple,
        size: 22,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 20),
      child: Divider(height: 1, thickness: 0.7),
    );
  }
}
