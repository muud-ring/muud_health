// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../services/onboarding_storage.dart';
import 'home_screen.dart';
import 'onboarding/onboarding_flow_screen.dart';

// ---- COLORS (same style as login) ----
const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kDarkText = Color(0xFF2A0B38);
const Color kBorderGrey = Color(0xFFCCCCCC);

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mobileOrEmailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  DateTime? _selectedDob;

  // password rule flags
  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecial =>
      RegExp(r'[!@#$%^&*?]').hasMatch(_passwordController.text);

  @override
  void dispose() {
    _mobileOrEmailController.dispose();
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text =
            '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  // ---------------- HANDLE SIGNUP ----------------
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDob == null) {
      setState(() {
        _errorMessage = 'Please select your date of birth.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final mobileOrEmail = _mobileOrEmailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final dobIsoString = _selectedDob!.toIso8601String();

    try {
      final result = await ApiService.signupUser(
        mobileOrEmail: mobileOrEmail,
        fullName: fullName,
        username: username,
        password: password,
        dateOfBirth: dobIsoString,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        final token = result['token'] as String;

        await TokenStorage.saveToken(token);
        await OnboardingStorage.setCompleted(false); // ensure onboarding needed

        // 🔀 go to ONBOARDING instead of Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingFlowScreen()),
          (route) => false,
        );
      } else {
        setState(() {
          _errorMessage =
              result['message'] as String? ??
              'Signup failed. Please try again.';
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

  Widget _buildPasswordRule(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check : Icons.close,
          size: 16,
          color: ok ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ok ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: kPrimaryPurple),
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(color: kPrimaryPurple, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: kPrimaryPurple),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // ---- Mobile / Email ----
                  const Text(
                    'Mobile number or email address',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _mobileOrEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your phone or email',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kBorderGrey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kPrimaryPurple,
                          width: 1.2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter mobile number or email.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ---- Full Name ----
                  const Text(
                    'Full name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your full name',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kBorderGrey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kPrimaryPurple,
                          width: 1.2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ---- Username ----
                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your username',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kBorderGrey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kPrimaryPurple,
                          width: 1.2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username.';
                      }
                      if (value.contains(' ')) {
                        return 'Username cannot contain spaces.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ---- Password ----
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kDarkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kBorderGrey,
                          width: 1,
                        ),
                      ),
                      // ✅ FIXED: OutlineInputBorder (not OutlineInputBoundary)
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
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      final text = value ?? '';
                      if (text.isEmpty) {
                        return 'Please enter a password.';
                      }
                      if (!_hasMinLength || !_hasNumber || !_hasSpecial) {
                        return 'Password doesn\'t meet all requirements.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  _buildPasswordRule('At least 8 characters', _hasMinLength),
                  _buildPasswordRule('At least 1 number', _hasNumber),
                  _buildPasswordRule(
                    'At least 1 special character (e.g., ! @ # ?)',
                    _hasSpecial,
                  ),

                  const SizedBox(height: 16),

                  // ---- DOB LABEL ----
                  Row(
                    children: const [
                      Text(
                        'Date of birth',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kDarkText,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.info_outline, size: 16, color: kPrimaryPurple),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ---- DOB FIELD ----
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'MM/DD/YYYY',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kBorderGrey,
                          width: 1,
                        ),
                      ),
                      // ✅ FIXED: OutlineInputBorder (not OutlineInputBoundary)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: kPrimaryPurple,
                          width: 1.2,
                        ),
                      ),
                      suffixIcon: const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: kPrimaryPurple,
                      ),
                    ),
                    onTap: _pickDateOfBirth,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please select your date of birth.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'People who use our service may have uploaded your contact information to MUUD. Learn More',
                    style: TextStyle(
                      fontSize: 12,
                      color: kDarkText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By signing up, you agree to our Terms of Service and Privacy Policy. You may receive SMS notifications from us and can opt out any time.',
                    style: TextStyle(
                      fontSize: 12,
                      color: kDarkText,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- SIGN UP BUTTON ----
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleSignup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryPurple.withOpacity(0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
