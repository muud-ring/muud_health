// lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

const Color kBrandPurple = Color(0xFF4B007F); // from Figma "4B007F"
const Color kLightPurple = Color(0xFFE9D7FF); // soft background / border
const Color kAppBackground = Colors.white;

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  final String token;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.token,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late String _mood;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _nameController = TextEditingController(text: p.fullName);
    _usernameController = TextEditingController(text: p.username);
    _bioController = TextEditingController(text: p.bio);
    _locationController = TextEditingController(text: p.location);
    _phoneController = TextEditingController(text: p.phone);
    _emailController = TextEditingController(text: p.email);
    _mood = p.mood.isNotEmpty ? p.mood : 'Overjoyed';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final updatedProfile = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      location: _locationController.text.trim(),
      phone: _phoneController.text.trim(),
      mood: _mood,
      // email + avatarUrl not editable yet in this screen
    );

    final result = await ApiService.updateMyProfile(
      widget.token,
      updatedProfile,
    );

    setState(() => _saving = false);

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, result); // send updated profile back
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
    }
  }

  void _pickMood() {
    // simple bottom sheet mood picker for now
    final moods = ['Overjoyed', 'Happy', 'Okay', 'Stressed', 'Sad'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          children: moods
              .map(
                (m) => ListTile(
                  title: Text(m),
                  onTap: () {
                    setState(() => _mood = m);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: kBrandPurple, fontSize: 14),
      hintStyle: const TextStyle(
        color: Color(0xFF9E9E9E), // input text color
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kLightPurple, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kBrandPurple, width: 1.6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackground,
      appBar: AppBar(
        backgroundColor: kAppBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBrandPurple),
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: const Text(
          'Edit your profile',
          style: TextStyle(
            color: kBrandPurple,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kBrandPurple),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: kBrandPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Avatar with purple ring + camera icon
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [kBrandPurple, Color(0xFFB57CFF)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: widget.profile.avatarUrl.isNotEmpty
                            ? Image.network(
                                widget.profile.avatarUrl,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : const Icon(
                                Icons.person,
                                size: 60,
                                color: kBrandPurple,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: add image picker later
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: kBrandPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mood pill
            GestureDetector(
              onTap: _pickMood,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: kBrandPurple, width: 1.4),
                  color: Colors.white,
                ),
                child: Text(
                  _mood,
                  style: const TextStyle(
                    color: kBrandPurple,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Name
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Name',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('', hint: 'Emily').copyWith(
                suffixIcon: _nameController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, color: kBrandPurple),
                        onPressed: () {
                          setState(() => _nameController.clear());
                        },
                      ),
              ),
            ),

            const SizedBox(height: 18),

            // Username
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Username',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _usernameController,
              decoration: _inputDecoration('', hint: '@emilylee'),
            ),

            const SizedBox(height: 18),

            // Bio
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bio',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: _inputDecoration(
                '',
                hint:
                    '👋 Hi, I’m Emily– Mom to Jonah, foodie, outdoor adventurer.',
              ),
            ),

            const SizedBox(height: 18),

            // Location
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Location',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: _inputDecoration('', hint: 'Los Angeles, CA'),
            ),

            const SizedBox(height: 18),

            // Phone
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Phone number',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('', hint: '123-456-7890'),
            ),

            const SizedBox(height: 18),

            // Email (read-only for now, styled the same)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Email',
                style: const TextStyle(
                  color: kBrandPurple,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: _inputDecoration('', hint: 'abc@email.com'),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
