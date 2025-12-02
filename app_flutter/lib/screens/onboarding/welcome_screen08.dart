import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen08 extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen08({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeScreen08> createState() => _WelcomeScreen08State();
}

class _WelcomeScreen08State extends State<WelcomeScreen08> {
  static const Color _primaryPurple = Color(0xFF5B288E);
  static const Color _secondaryPurple = Color(0xFF9A29CF);

  bool _isSaving = false;
  String? _selectedKey;

  final List<_ExpectationItem> _items = const [
    _ExpectationItem(
      keyValue: 'customize_journal',
      text: 'Customize journal and journey',
    ),
    _ExpectationItem(
      keyValue: 'prepare_sessions',
      text: 'Prepare your first wellness sessions',
    ),
    _ExpectationItem(
      keyValue: 'create_optimal_plan',
      text: 'Creating your optimal plan to enhance your mood',
    ),
  ];

  Future<void> _handleContinue() async {
    if (_selectedKey == null || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // IMPORTANT: this key must exist in the backend allowed fields
      await OnboardingService.updateOnboarding({
        'preparingChoice': _selectedKey,
      });
    } catch (e) {
      debugPrint('Failed to save onboarding preparingSelection: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save your preferences. We’ll keep going anyway 👍',
            ),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _isSaving = false);

      // Always move to the next step (Home)
      widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedKey != null && !_isSaving;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                "Just a moment while we get\nMUUD ready for you…",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: _primaryPurple,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Thank you for your patience :) We’re here to help you feel better.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: _secondaryPurple,
                ),
              ),

              const SizedBox(height: 24),

              // Three radio-style cards
              ..._items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExpectationCard(
                    item: item,
                    selected: _selectedKey == item.keyValue,
                    onTap: () {
                      setState(() => _selectedKey = item.keyValue);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

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

class _ExpectationItem {
  final String keyValue;
  final String text;

  const _ExpectationItem({required this.keyValue, required this.text});
}

class _ExpectationCard extends StatelessWidget {
  final _ExpectationItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ExpectationCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  static const Color _primaryPurple = Color(0xFF5B288E);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? _primaryPurple : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Radio circle
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryPurple, width: 2),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 14,
                          height: 14,
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
                  item.text,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
