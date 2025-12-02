import 'package:flutter/material.dart';
import '../../services/onboarding_service.dart';

class WelcomeScreen05 extends StatefulWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const WelcomeScreen05({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  State<WelcomeScreen05> createState() => _WelcomeScreen05State();
}

class _WelcomeScreen05State extends State<WelcomeScreen05> {
  static const Color _primaryPurple = Color(0xFF5B288E);

  bool _isSaving = false;

  Future<void> _handleChoice(bool allow) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      // Save the choice to backend
      await OnboardingService.updateOnboarding({'notificationsEnabled': allow});

      if (!mounted) return;
      if (allow) {
        widget.onAllow();
      } else {
        widget.onDeny();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save your notification preference. Please try again.',
          ),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            // Back arrow aligned left
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                  color: _primaryPurple,
                ),
                onPressed: _isSaving ? null : widget.onDeny,
              ),
            ),

            const SizedBox(height: 16),

            // Illustration centered
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/onboarding/notifications.png',
                  fit: BoxFit.contain,
                  // tweak height if you want it larger/smaller
                  height: 260,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'MUUD wants to send you\nnotifications',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: _primaryPurple,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'MUUD’s notifications will remind you to log\n'
              'your journal/journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                color: _primaryPurple,
              ),
            ),

            const SizedBox(height: 32),

            // Allow notifications button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () => _handleChoice(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _primaryPurple,
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
                        'Allow notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // No thanks button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => _handleChoice(false),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: _primaryPurple, width: 1.5),
                ),
                child: const Text(
                  'No thanks',
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
    );
  }
}
