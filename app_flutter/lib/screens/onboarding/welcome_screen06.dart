import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen06 extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const WelcomeScreen06({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<WelcomeScreen06> createState() => _WelcomeScreen06State();
}

class _WelcomeScreen06State extends State<WelcomeScreen06> {
  static const Color purple = Color(0xFF6A1B9A);

  bool _isSaving = false;

  // Support options (same order as your design)
  final List<_SupportOption> _options = const [
    _SupportOption(
      keyValue: "navigate_emotions",
      text:
          "Discover strategies to help you navigate and work with your emotions.",
      image: "assets/images/onboarding/01Screen05.png",
    ),
    _SupportOption(
      keyValue: "uncover_patterns",
      text:
          "Uncover patterns by reflecting through your daily journal or journey.",
      image: "assets/images/onboarding/02Screen05.png",
    ),
    _SupportOption(
      keyValue: "wellness_sessions",
      text: "Find the right wellness session tailored to your needs.",
      image: "assets/images/onboarding/03Screen05.png",
    ),
  ];

  // Selected items
  final List<String> _selectedKeys = [];

  void _toggleSelect(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedKeys.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Backend expects: supportOptions: [...]
      await OnboardingService.updateOnboarding({
        'supportOptions': _selectedKeys,
      });

      widget.onContinue();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not save your choices. We’ll continue anyway."),
        ),
      );
      widget.onContinue(); // still continue
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedKeys.isNotEmpty && !_isSaving;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Text(
                "Great! Here’s how MUUD Health can support you:",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  color: purple,
                ),
              ),

              const SizedBox(height: 24),

              // Render support cards
              ..._options.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _SupportCard(
                    option: opt,
                    selected: _selectedKeys.contains(opt.keyValue),
                    onTap: () => _toggleSelect(opt.keyValue),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canContinue ? _handleContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canContinue
                        ? purple
                        : purple.withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: widget.onSkip,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: purple, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: const Text(
                    "Skip setup",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: purple,
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

/// Option structure
class _SupportOption {
  final String keyValue;
  final String text;
  final String image;

  const _SupportOption({
    required this.keyValue,
    required this.text,
    required this.image,
  });
}

/// Card widget
class _SupportCard extends StatelessWidget {
  final _SupportOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SupportCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6A1B9A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? purple : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              option.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Image.asset(option.image, height: 120),
          ],
        ),
      ),
    );
  }
}
