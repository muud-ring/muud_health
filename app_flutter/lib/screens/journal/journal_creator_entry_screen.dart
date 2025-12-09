// lib/screens/journal/journal_creator_entry_screen.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'journal_edit_screen.dart';
import 'package:app_flutter/models/journal/journal_draft.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalCreatorEntryScreen extends StatefulWidget {
  const JournalCreatorEntryScreen({super.key});

  @override
  State<JournalCreatorEntryScreen> createState() =>
      _JournalCreatorEntryScreenState();
}

class _JournalCreatorEntryScreenState extends State<JournalCreatorEntryScreen> {
  final ImagePicker _picker = ImagePicker();

  // 👇 Current visibility setting (Public / Inner Circle / Connections)
  String _visibility = 'Public';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1440,
      );

      if (!mounted || picked == null) return;

      // Go to edit screen with the selected image and current visibility
      final draft = await Navigator.push<JournalDraft>(
        context,
        MaterialPageRoute(
          builder: (_) => JournalEditScreen(
            imagePath: picked.path,
            initialVisibility: _visibility,
          ),
        ),
      );

      if (!mounted) return;

      if (draft != null) {
        // Pass the draft back to Home
        Navigator.pop(context, draft);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not pick image: $e')));
    }
  }

  Future<void> _openVisibilitySelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose who your post is visible to',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              _VisibilityTile(
                label: 'Public',
                icon: Icons.public,
                isSelected: _visibility == 'Public',
                onTap: () => Navigator.pop(ctx, 'Public'),
              ),
              _VisibilityTile(
                label: 'Inner Circle',
                icon: Icons.group_work_outlined,
                isSelected: _visibility == 'Inner Circle',
                onTap: () => Navigator.pop(ctx, 'Inner Circle'),
              ),
              _VisibilityTile(
                label: 'Connections',
                icon: Icons.people_alt_outlined,
                isSelected: _visibility == 'Connections',
                onTap: () => Navigator.pop(ctx, 'Connections'),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() => _visibility = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ----- Fake camera preview area -----
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Text(
                    'Camera preview\n(we use system camera when you tap the button)',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ),
            ),

            // ----- Top bar (X + Next disabled) -----
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ----- Bottom controls area (Creator Tool) -----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Visibility chip row
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _openVisibilitySelector,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color(0xFFF3ECFF),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.public,
                                  size: 18,
                                  color: kPrimaryPurple,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _visibility,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: kPrimaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _openVisibilitySelector,
                          child: Text(
                            'Send to',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Main bottom row: gallery, shutter, mic
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Gallery button
                        IconButton(
                          icon: const Icon(
                            Icons.photo_library_outlined,
                            size: 28,
                            color: kPrimaryPurple,
                          ),
                          onPressed: () => _pickImage(ImageSource.gallery),
                        ),

                        // Big shutter button (camera)
                        GestureDetector(
                          onTap: () => _pickImage(ImageSource.camera),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: kPrimaryPurple,
                                width: 4,
                              ),
                            ),
                            child: const Center(
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: kPrimaryPurple,
                              ),
                            ),
                          ),
                        ),

                        // Mic icon (UI only for now)
                        IconButton(
                          icon: const Icon(
                            Icons.mic_none,
                            size: 28,
                            color: kPrimaryPurple,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Voice recording will be added later.',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Thin drag handle-style line
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibilityTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VisibilityTile({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: kPrimaryPurple),
      title: Text(label, style: const TextStyle(fontSize: 15)),
      trailing: isSelected
          ? const Icon(Icons.check, color: kPrimaryPurple)
          : null,
    );
  }
}
