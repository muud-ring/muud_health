import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen03 extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen03({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeScreen03> createState() => _WelcomeScreen03State();
}

class _WelcomeScreen03State extends State<WelcomeScreen03> {
  static const Color _primaryPurple = Color(0xFF5B288E);
  static const Color _disabledPurple = Color(0xFF9A29CF);

  final List<String> _options = const [
    'Improve mood',
    'Increase focus and productivity',
    'Self-improvement',
    'Reduce stress or anxiety',
    'Other',
  ];

  int? _selectedIndex;
  bool _isSaving = false;

  bool get _canContinue => _selectedIndex != null && !_isSaving;

  void _onOptionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedIndex == null || _isSaving) return;

    final focus = _options[_selectedIndex!];

    setState(() => _isSaving = true);

    try {
      // 🔹 Call backend: PUT /api/profile/onboarding { focus: "<value>" }
      await OnboardingService.updateOnboarding({'focus': focus});

      if (!mounted) return;
      widget.onContinue();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your answer. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Back arrow
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: _primaryPurple,
            ),
            onPressed: _isSaving ? null : widget.onSkip,
          ),

          const SizedBox(height: 24),

          const Text(
            "Is there anything specific\nyou’d like to focus on?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: _primaryPurple,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Your answers won’t prevent you from\n"
            "accessing any wellness tips, and you can\n"
            "adjust your settings later.",
            style: TextStyle(fontSize: 16, height: 1.4, color: _primaryPurple),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final selected = _selectedIndex == index;
                return _FocusOptionCard(
                  label: _options[index],
                  selected: selected,
                  onTap: _isSaving ? null : () => _onOptionTap(index),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canContinue ? _handleContinue : null,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _canContinue
                    ? _primaryPurple
                    : _disabledPurple,
                disabledBackgroundColor: _disabledPurple,
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
    );
  }
}

class _FocusOptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _FocusOptionCard({
    required this.label,
    required this.selected,
    this.onTap,
  });

  static const Color _primaryPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000), // subtle shadow
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryPurple, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryPurple,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF222222),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
