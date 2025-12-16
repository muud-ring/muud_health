import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/people/person_summary.dart';
import 'people_profile_screen.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);
const Color kLightPurple = Color(0xFFDAC9E8);

class PeopleScreen extends StatefulWidget {
  const PeopleScreen({super.key});

  @override
  State<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
  late Future<List<PersonSummary>> _peopleFuture;

  @override
  void initState() {
    super.initState();
    _peopleFuture = ApiService.fetchPeople();
  }

  Future<void> _refresh() async {
    setState(() {
      _peopleFuture = ApiService.fetchPeople();
    });
    await _peopleFuture;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // INNER CIRCLE
            // ----------------------------------------------------
            _sectionHeader("Inner Circle", onSeeAll: () {}),
            const SizedBox(height: 20),
            _EmptySectionCard(
              iconPath: "assets/images/people/diversity_2.png",
              title: "No Inner Circle",
              subtitle: "Your inner circles will show up here.",
              buttonLabel: "Add friends",
              onPressed: () {},
            ),

            const SizedBox(height: 32),

            // ----------------------------------------------------
            // CONNECTIONS
            // ----------------------------------------------------
            _sectionHeader("Connections", onSeeAll: () {}),
            const SizedBox(height: 20),
            _EmptySectionCard(
              iconPath: "assets/images/people/group_add.png",
              title: "No Connections",
              subtitle: "Your connections will show up here.",
              buttonLabel: "Add friends",
              onPressed: () {},
            ),

            const SizedBox(height: 32),

            // ----------------------------------------------------
            // SUGGESTED FRIENDS (REAL DATA)
            // ----------------------------------------------------
            _sectionHeader("Suggested Friends", onSeeAll: () {}),
            const SizedBox(height: 16),

            FutureBuilder<List<PersonSummary>>(
              future: _peopleFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snap.hasError) {
                  return _InlineError(
                    message: "Failed to load people",
                    onRetry: _refresh,
                  );
                }

                final people = snap.data ?? [];
                if (people.isEmpty) {
                  return const _EmptySuggested();
                }

                return _SuggestedFriendsRow(people: people);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- SECTION HEADER ----------
Widget _sectionHeader(String title, {required VoidCallback onSeeAll}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: kPrimaryPurple,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      GestureDetector(
        onTap: onSeeAll,
        child: const Text(
          "See All",
          style: TextStyle(
            color: kPrimaryPurple,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// ---------- EMPTY STATE CARD ----------
class _EmptySectionCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _EmptySectionCard({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 56, color: kLightPurple),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: kPrimaryPurple,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Suggested Friends EMPTY ----------
class _EmptySuggested extends StatelessWidget {
  const _EmptySuggested();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
        child: Text(
          "No suggestions yet",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

// ---------- Error Row ----------
class _InlineError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => onRetry(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
              ),
              child: const Text("Retry", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- SUGGESTED FRIENDS ROW (REAL DATA + TAP TO PROFILE) ----------
class _SuggestedFriendsRow extends StatelessWidget {
  final List<PersonSummary> people;
  const _SuggestedFriendsRow({required this.people});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: people.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = people[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PeopleProfileScreen(personId: p.id),
                ),
              );
            },
            child: Column(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: kLightPurple,
                  backgroundImage:
                      (p.avatarUrl != null && p.avatarUrl!.isNotEmpty)
                      ? NetworkImage(p.avatarUrl!)
                      : null,
                  child: (p.avatarUrl == null || p.avatarUrl!.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 88,
                  child: Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  p.username != null && p.username!.isNotEmpty
                      ? "@${p.username}"
                      : "",
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
