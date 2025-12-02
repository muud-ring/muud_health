import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen07 extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen07({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeScreen07> createState() => _WelcomeScreen07State();
}

class _WelcomeScreen07State extends State<WelcomeScreen07> {
  static const Color _primaryPurple = Color(0xFF5B288E);
  static const Color _secondaryPurple = Color(0xFF9A29CF); // subtitle color

  String? _selectedMood;
  bool _isSaving = false;

  final List<_MoodItem> _moods = const [
    _MoodItem(
      keyValue: 'happy',
      label: 'Happy',
      emoji: '😀',
      ringColor: Color(0xFF7D3CFF),
    ),
    _MoodItem(
      keyValue: 'fear',
      label: 'Fear',
      emoji: '😱',
      ringColor: Color(0xFFFFC400),
    ),
    _MoodItem(
      keyValue: 'dislike',
      label: 'Dislike',
      emoji: '🤢',
      ringColor: Color(0xFF33A852),
    ),
    _MoodItem(
      keyValue: 'sadness',
      label: 'Sadness',
      emoji: '😭',
      ringColor: Color(0xFF007BFF),
    ),
    _MoodItem(
      keyValue: 'angry',
      label: 'Angry',
      emoji: '😡',
      ringColor: Color(0xFFFF3B30),
    ),
    _MoodItem(
      keyValue: 'surprised',
      label: 'Surprised',
      emoji: '🤯',
      ringColor: Color(0xFFFF9500),
    ),
  ];

  Future<void> _handleContinue() async {
    if (_selectedMood == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Try to save first MUUD check-in to onboarding data
      await OnboardingService.updateOnboarding({'initialMood': _selectedMood});
    } catch (e) {
      debugPrint('Failed to save onboarding mood: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save your mood. We’ll keep going anyway 👍',
            ),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);

      // ALWAYS move to the next screen (WelcomeScreen08)
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedMood != null && !_isSaving;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                "Let’s get started with your\nfirst MUUD check-in",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: _primaryPurple,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Tap the MUUD that best describes how you feel right now",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: _secondaryPurple,
                ),
              ),

              const SizedBox(height: 32),

              // Emoji grid
              Center(
                child: Wrap(
                  spacing: 40,
                  runSpacing: 40,
                  children: _moods.map((mood) {
                    final bool isSelected = _selectedMood == mood.keyValue;
                    return _MoodOption(
                      mood: mood,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedMood = mood.keyValue);
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 40),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: canContinue
                        ? _primaryPurple
                        : const Color(0xFFB59AD8), // disabled lavender
                    minimumSize: const Size(double.infinity, 56),
                    shape: const StadiumBorder(),
                    foregroundColor: Colors.white,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip setup
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : widget.onSkip,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: _primaryPurple, width: 1.5),
                  ),
                  child: const Text(
                    'Skip setup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodItem {
  final String keyValue;
  final String label;
  final String emoji;
  final Color ringColor;

  const _MoodItem({
    required this.keyValue,
    required this.label,
    required this.emoji,
    required this.ringColor,
  });
}

class _MoodOption extends StatelessWidget {
  final _MoodItem mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color ringColor = mood.ringColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isSelected
                  ? LinearGradient(
                      colors: [ringColor, ringColor.withOpacity(0.6)],
                    )
                  : const LinearGradient(
                      colors: [Colors.transparent, Colors.transparent],
                    ),
            ),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(mood.emoji, style: const TextStyle(fontSize: 40)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mood.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF5B288E),
          ),
        ),
      ],
    );
  }
}
