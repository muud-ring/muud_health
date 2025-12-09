import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/token_storage.dart';
import '../models/user_profile.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'home_tab.dart';
import 'package:app_flutter/screens/trends/trends_screen.dart';
import 'edit_profile_screen.dart';
import 'package:app_flutter/widgets/home/profile_card.dart';

// 👉 People screen
import 'package:app_flutter/screens/people_screen.dart';

// 👉 Journal frontend draft + backend models
import 'package:app_flutter/screens/journal/journal_creator_entry_screen.dart';
import 'package:app_flutter/models/journal/journal_draft.dart';
import 'package:app_flutter/models/journal/journal_entry.dart';
import 'package:app_flutter/widgets/home/journal_preview_card.dart';
import 'package:app_flutter/widgets/home/journal_entry_card.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fullName = "Alex";
  int _currentIndex = 0;

  UserProfile? _profile;
  String? _authToken;

  // Last created journal (local-only, used for immediate preview with imagePath)
  JournalDraft? _lastJournalDraft;

  // Journals from backend
  List<JournalEntry> _journals = [];

  @override
  void initState() {
    super.initState();
    _loadProtectedProfileAndJournals();
  }

  Future<void> _loadProtectedProfileAndJournals() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    _authToken = token;

    try {
      await ApiService.getProtectedData(token);
      final profile = await ApiService.getMyProfile(token);
      final journals = await ApiService.getMyJournals(token);

      if (!mounted) return;

      setState(() {
        _profile = profile;
        if (profile != null && profile.fullName.isNotEmpty) {
          fullName = profile.fullName;
        }
        _journals = journals;
      });
    } catch (e) {
      print('Error loading profile/journals: $e');
    }
  }

  Future<void> _refreshJournals() async {
    if (_authToken == null) return;

    try {
      final journals = await ApiService.getMyJournals(_authToken!);
      if (!mounted) return;
      setState(() {
        _journals = journals;
      });
    } catch (e) {
      print('Error refreshing journals: $e');
    }
  }

  Future<void> _logout() async {
    await TokenStorage.removeToken();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openEditProfile() async {
    if (_profile == null || _authToken == null) return;

    final updated = await Navigator.push<UserProfile?>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(profile: _profile!, token: _authToken!),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _profile = updated;
        fullName = updated.fullName;
      });
    }
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        if (_profile == null) {
          return HomeTab(fullName: fullName);
        }
        return Column(
          children: [
            ProfileCard(profile: _profile!, onEdit: _openEditProfile),
            const SizedBox(height: 16),

            // 👉 Prefer backend journal if available
            if (_journals.isNotEmpty) ...[
              JournalEntryCard(entry: _journals.first),
              const SizedBox(height: 16),
            ] else if (_lastJournalDraft != null) ...[
              // Fallback: show local draft (with real imagePath)
              JournalPreviewCard(draft: _lastJournalDraft!),
              const SizedBox(height: 16),
            ],

            Expanded(child: HomeTab(fullName: fullName)),
          ],
        );

      case 1:
        return const TrendsScreen();

      case 2:
        // Center + tab is not used anymore, but we keep placeholder
        return const Center(child: Text('New Entry (+)'));

      case 3:
        return const PeopleScreen();

      case 4:
        return const Center(child: Text('Explore tab (coming soon)'));

      default:
        return HomeTab(fullName: fullName);
    }
  }

  String get _currentTitle {
    switch (_currentIndex) {
      case 0:
        return "Home";
      case 1:
        return "Trends";
      case 2:
        return "New Entry";
      case 3:
        return "People";
      case 4:
        return "Explore";
      default:
        return "Home";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            // ------------ TOP NAV BAR ------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 26),
                    color: kPrimaryPurple,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  IconButton(
                    icon: const Icon(Icons.lock_outline, size: 26),
                    color: kPrimaryPurple,
                    onPressed: () {},
                  ),

                  const Spacer(),

                  Text(
                    _currentTitle,
                    style: const TextStyle(
                      color: kPrimaryPurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),

                  const Spacer(),

                  IconButton(
                    icon: const Icon(Icons.stacked_bar_chart, size: 26),
                    color: kPrimaryPurple,
                    onPressed: () {},
                  ),

                  IconButton(
                    icon: const Icon(Icons.logout, size: 26),
                    color: kPrimaryPurple,
                    onPressed: _logout,
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: _buildCurrentTab(),
              ),
            ),
          ],
        ),
      ),

      // ------------ BOTTOM NAV BAR ------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isSelected: _currentIndex == 0,
              onTap: () => setState(() => _currentIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.show_chart,
              label: 'Trends',
              isSelected: _currentIndex == 1,
              onTap: () => setState(() => _currentIndex = 1),
            ),

            // 👉 Center + button opens Journal Creator and awaits result
            GestureDetector(
              onTap: () async {
                final draft = await Navigator.push<JournalDraft>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JournalCreatorEntryScreen(),
                  ),
                );

                if (draft != null && mounted) {
                  setState(() {
                    _lastJournalDraft = draft;
                    _currentIndex = 0; // ensure we’re on Home tab
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Journal saved.')),
                  );

                  // Also refresh from backend so card reflects real data
                  _refreshJournals();
                }
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kPrimaryPurple,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),

            _BottomNavItem(
              icon: Icons.people_alt_outlined,
              label: 'People',
              isSelected: _currentIndex == 3,
              onTap: () => setState(() => _currentIndex = 3),
            ),
            _BottomNavItem(
              icon: Icons.search,
              label: 'Explore',
              isSelected: _currentIndex == 4,
              onTap: () => setState(() => _currentIndex = 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? kPrimaryPurple : Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
