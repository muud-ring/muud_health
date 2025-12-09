// lib/screens/journal/journal_edit_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'journal_preview_screen.dart';
import 'package:app_flutter/models/journal/journal_draft.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class JournalEditScreen extends StatefulWidget {
  final String imagePath;
  final String initialVisibility;

  const JournalEditScreen({
    super.key,
    required this.imagePath,
    required this.initialVisibility,
  });

  @override
  State<JournalEditScreen> createState() => _JournalEditScreenState();
}

class _JournalEditScreenState extends State<JournalEditScreen> {
  String _caption = '';
  bool _showCaptionOverlay = false;

  String? _emoji; // selected emoji sticker
  bool _showEmojiOverlay = false;

  late String _visibility;

  @override
  void initState() {
    super.initState();
    _visibility = widget.initialVisibility;
  }

  // ---------- TEXT (T) – bottom sheet caption input ----------
  Future<void> _addOrEditTextCaption() async {
    final controller = TextEditingController(text: _caption);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Add caption',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: '#happy, #ootd, #healing',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (value) =>
                    Navigator.pop(ctx, value.trim()), // return = Done
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _caption = result;
        _showCaptionOverlay = true;
      });
    }
  }

  // ---------- EMOJI (😀) ----------
  Future<void> _chooseEmoji() async {
    const emojis = ['😀', '😊', '🥳', '😌', '🤍'];

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
                'Choose a sticker',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: emojis
                    .map(
                      (e) => GestureDetector(
                        onTap: () => Navigator.pop(ctx, e),
                        child: Text(e, style: const TextStyle(fontSize: 32)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null && mounted) {
      setState(() {
        _emoji = selected;
        _showEmojiOverlay = true;
      });
    }
  }

  // ---------- VISIBILITY PICKER ----------
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

  // ---------- HELPERS ----------
  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature will be added later.')));
  }

  void _clearOverlays() {
    setState(() {
      _caption = '';
      _showCaptionOverlay = false;
      _emoji = null;
      _showEmojiOverlay = false;
    });
  }

  Future<void> _goToPreview() async {
    final draft = await Navigator.push<JournalDraft>(
      context,
      MaterialPageRoute(
        builder: (_) => JournalPreviewScreen(
          imagePath: widget.imagePath,
          caption: _caption,
          visibility: _visibility,
        ),
      ),
    );

    if (!mounted) return;

    if (draft != null) {
      // Return draft back to Creator screen
      Navigator.pop(context, draft);
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.imagePath);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ----- Photo full screen -----
            Positioned.fill(
              child: Center(child: Image.file(file, fit: BoxFit.contain)),
            ),

            // ----- Emoji overlay (near top center) -----
            if (_showEmojiOverlay && _emoji != null)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(_emoji!, style: const TextStyle(fontSize: 48)),
                ),
              ),

            // ----- Caption overlay (bottom center, above bottom bar) -----
            if (_showCaptionOverlay && _caption.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 140,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: Colors.black.withOpacity(0.5),
                  child: Text(
                    _caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            // ----- Top bar (back + Next) -----
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _goToPreview,
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: kPrimaryPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== RIGHT TOOLBAR (Figma-like pill) =====
            Positioned(
              top: 120,
              right: 16,
              child: Container(
                width: 56,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ToolIconButton(
                      assetPath: 'assets/icons/add_reaction.png',
                      onTap: _chooseEmoji,
                    ),
                    const SizedBox(height: 14),
                    _ToolIconButton(
                      assetPath: 'assets/icons/title.png',
                      onTap: _addOrEditTextCaption,
                    ),
                    const SizedBox(height: 14),
                    _ToolIconButton(
                      assetPath: 'assets/icons/content_cut.png',
                      onTap: () => _showComingSoon('Advanced edit tools'),
                    ),
                    const SizedBox(height: 14),
                    _ToolIconButton(
                      assetPath: 'assets/icons/music_note.png',
                      onTap: () => _showComingSoon('Music / voice overlay'),
                    ),
                    const SizedBox(height: 14),
                    _ToolIconButton(
                      assetPath: 'assets/icons/ink_eraser.png',
                      onTap: _clearOverlays,
                    ),
                    const SizedBox(height: 14),
                    _ToolIconButton(
                      assetPath: 'assets/icons/Group 1000003501.png',
                      onTap: () => _showComingSoon('Crop'),
                    ),
                  ],
                ),
              ),
            ),

            // ----- Bottom bar (visibility + camera/mic + Send to) -----
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top row: visibility chip + Send to text
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
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottom row: camera, mic, big Send button
                    Row(
                      children: [
                        // Camera icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3ECFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.photo_camera_outlined,
                              size: 22,
                              color: kPrimaryPurple,
                            ),
                            onPressed: () => _showComingSoon('Extra photo'),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Mic icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3ECFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.mic_none,
                              size: 22,
                              color: kPrimaryPurple,
                            ),
                            onPressed: () =>
                                _showComingSoon('Voice note recording'),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Big Send button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _goToPreview,
                            child: const Text(
                              'Send to',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
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

class _ToolIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _ToolIconButton({required this.assetPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Image.asset(
          assetPath,
          width: 22,
          height: 22,
          fit: BoxFit.contain,
          color: Colors.white,
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
      title: Text(label),
      trailing: isSelected
          ? const Icon(Icons.check, color: kPrimaryPurple)
          : null,
    );
  }
}
