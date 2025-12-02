import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen04 extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen04({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeScreen04> createState() => _WelcomeScreen04State();
}

class _WelcomeScreen04State extends State<WelcomeScreen04> {
  static const Color _primaryPurple = Color(0xFF5B288E);
  static const Color _disabledPurple = Color(0xFF9A29CF);

  final List<_ActivityOption> _options = const [
    _ActivityOption(label: 'Meditation', emoji: '🧘'),
    _ActivityOption(label: 'Exercise', emoji: '🏃‍♀️'),
    _ActivityOption(label: 'Reading', emoji: '📚'),
    _ActivityOption(label: 'Cooking', emoji: '👩‍🍳'),
    _ActivityOption(label: 'Social', emoji: '🕺'),
    _ActivityOption(label: 'Pet care', emoji: '🐩'),
  ];

  final Set<int> _selectedIndexes = {};
  bool _isSaving = false;

  bool get _canContinue => _selectedIndexes.isNotEmpty && !_isSaving;

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndexes.contains(index)) {
        _selectedIndexes.remove(index);
      } else {
        _selectedIndexes.add(index);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!_canContinue) return;

    final activities = _selectedIndexes.map((i) => _options[i].label).toList();

    setState(() => _isSaving = true);

    try {
      await OnboardingService.updateOnboarding({'activities': activities});

      if (!mounted) return;
      widget.onContinue();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save your activities. Please try again.'),
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
            'Do you have any preferred\ntypes of activities?',
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

          // Grid of cards
          Expanded(
            child: GridView.builder(
              itemCount: _options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final option = _options[index];
                final selected = _selectedIndexes.contains(index);
                return _ActivityCard(
                  option: option,
                  selected: selected,
                  onTap: _isSaving ? null : () => _toggleSelection(index),
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

class _ActivityOption {
  final String label;
  final String emoji;

  const _ActivityOption({required this.label, required this.emoji});
}

class _ActivityCard extends StatelessWidget {
  final _ActivityOption option;
  final bool selected;
  final VoidCallback? onTap;

  const _ActivityCard({
    required this.option,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(24);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: selected ? const Color(0xFF5B288E) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
