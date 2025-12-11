import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/user_storage.dart';
import '../services/apple_sign_in_service.dart';
import 'splash_screen.dart';
import 'signup_screen.dart';

// ---------- COLORS FROM FIGMA ----------
const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kDarkText = Color(0xFF2A0B38);
const Color kBorderGrey = Color(0xFFCCCCCC);

// ---------- LOGIN SCREEN ----------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // ---------- GOOGLE SIGN-IN ----------
  static const String _googleClientId =
      '745123377800-trlcdnr3ac8sh74s6ldb5re5uh0hf2fi.apps.googleusercontent.com';

  bool _isGoogleLoading = false;
  bool _googleInitialized = false;

  // ---------- FACEBOOK LOADING ----------
  bool _isFacebookLoading = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;

    final GoogleSignIn signIn = GoogleSignIn.instance;
    await signIn.initialize(clientId: _googleClientId);

    _googleInitialized = true;
  }

  // ---------------- VALIDATION ----------------
  bool _validateInputs() {
    final id = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Mobile/email and password are required.';
      });
      return false;
    }

    return true;
  }

  // ---------------- NORMAL LOGIN LOGIC ----------------
  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await ApiService.loginUser(identifier, password);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final token = result['token'] as String;
        final user = result['user'];

        await TokenStorage.saveToken(token);

        if (user != null && user['fullName'] != null) {
          await UserStorage.saveFullName(user['fullName']);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] as String? ?? 'Login failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }

  // ---------------- GOOGLE LOGIN LOGIC ----------------
  Future<void> _handleGoogleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      await _ensureGoogleInitialized();

      final GoogleSignIn signIn = GoogleSignIn.instance;

      if (!signIn.supportsAuthenticate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In not supported on this platform.'),
          ),
        );
        setState(() => _isGoogleLoading = false);
        return;
      }

      final GoogleSignInAccount user = await signIn.authenticate();
      final GoogleSignInAuthentication googleAuth = user.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google login failed: No ID token')),
        );
        setState(() => _isGoogleLoading = false);
        return;
      }

      final result = await ApiService.googleLogin(idToken);

      if (!mounted) return;

      if (result['success'] == true) {
        final token = result['token'];
        final userData = result['user'];

        await TokenStorage.saveToken(token);

        if (userData != null && userData['fullName'] != null) {
          await UserStorage.saveFullName(userData['fullName']);
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      } else {
        setState(() {
          _errorMessage =
              result['message'] as String? ?? 'Google login failed.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Google Sign-In error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  // ---------------- APPLE LOGIN LOGIC ----------------
  Future<void> _handleAppleSignIn() async {
    final credential = await AppleSignInService.signIn();
    if (!mounted) return;

    if (credential == null || credential.identityToken == null) {
      return; // user cancelled
    }

    final fullName = [
      credential.givenName ?? '',
      credential.familyName ?? '',
    ].join(' ').trim();

    try {
      final result = await ApiService.appleLogin(
        idToken: credential.identityToken!,
        fullName: fullName.isNotEmpty ? fullName : null,
      );

      final token = result['token'];
      final userData = result['user'];

      await TokenStorage.saveToken(token);

      if (userData != null && userData['fullName'] != null) {
        await UserStorage.saveFullName(userData['fullName']);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Apple Sign-In error: $e';
      });
    }
  }

  // ---------------- FACEBOOK LOGIN LOGIC (NEW) ----------------
  Future<void> _handleFacebookSignIn() async {
    if (_isFacebookLoading) return;

    setState(() {
      _isFacebookLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Trigger Facebook login
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );

      if (result.status != LoginStatus.success) {
        // user cancelled or error
        setState(() {
          _errorMessage = 'Facebook login cancelled or failed.';
        });
        return;
      }

      // 2) Get access token
      final accessToken = result.accessToken?.token;
      if (accessToken == null) {
        setState(() {
          _errorMessage = 'Facebook login failed: No access token.';
        });
        return;
      }

      // 3) Send access token to backend
      final fbResult = await ApiService.facebookLogin(accessToken);

      final token = fbResult['token'];
      final userData = fbResult['user'];

      await TokenStorage.saveToken(token);

      if (userData != null && userData['fullName'] != null) {
        await UserStorage.saveFullName(userData['fullName']);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Facebook Sign-In error: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------- UI STARTS HERE ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // ---------- LOGO ----------
              Center(
                child: Image.asset(
                  'assets/images/muud_logo_color.png',
                  height: 110,
                ),
              ),

              const SizedBox(height: 40),

              if (_errorMessage != null) ...[
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],

              // ---------- EMAIL LABEL ----------
              const Text(
                'Email address',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 8),

              // ---------- EMAIL FIELD ----------
              TextField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderGrey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: kPrimaryPurple,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------- PASSWORD LABEL ----------
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 8),

              // ---------- PASSWORD FIELD ----------
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kBorderGrey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: kPrimaryPurple,
                      width: 1.2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ---------- FORGOT PASSWORD ----------
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Forgot username or password?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: kPrimaryPurple,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ---------- LOGIN BUTTON ----------
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ---------- DIVIDER ----------
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kDarkText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade300, thickness: 1),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ---------- SOCIAL BUTTONS ----------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SocialIconButton(
                    assetPath: 'assets/images/google.png',
                    onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                  ),
                  const SizedBox(width: 16),
                  _SocialIconButton(
                    assetPath: 'assets/images/apple.png',
                    onTap: _handleAppleSignIn,
                  ),
                  const SizedBox(width: 16),
                  _SocialIconButton(
                    assetPath: 'assets/images/facebook.png',
                    onTap: _isFacebookLoading ? null : _handleFacebookSignIn,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ---------- JOIN MUUD BUTTON ----------
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryPurple, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Join MUUD Today',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryPurple,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ---------- FOOTER ----------
              Column(
                children: [
                  Text(
                    'Privacy Policy | Terms of Use',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HIPAA Notice',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- SOCIAL ICON BUTTON ----------
class _SocialIconButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback? onTap;

  const _SocialIconButton({required this.assetPath, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderGrey, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
