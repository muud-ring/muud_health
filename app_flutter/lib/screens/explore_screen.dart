// lib/screens/explore_screen.dart

import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF5B288E);

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeScreen already gives padding + top bar.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- SEARCH ----------
          TextField(
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F4F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---------- FILTER CHIPS ----------
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _FilterChip(label: 'All', isSelected: true),
                SizedBox(width: 8),
                _FilterChip(label: 'Family'),
                SizedBox(width: 8),
                _FilterChip(label: 'Friends'),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ---------- EMPTY POSTS ----------
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.insert_drive_file_outlined,
                  size: 52,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Empty Posts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2A0B38),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your posts will show up here.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // For now this is just an empty-state button.
                      // Later we can wire this to the journaling flow.
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Start Journaling',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ---------- RECOMMENDATIONS HEADER ----------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2A0B38),
                ),
              ),
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ---------- RECOMMENDATIONS GRID ----------
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _RecommendationCard(emoji: '🧘‍♀️', label: 'Meditation'),
              _RecommendationCard(emoji: '🍳', label: 'Cooking'),
              _RecommendationCard(emoji: '🏃‍♂️', label: 'Exercise'),
              _RecommendationCard(emoji: '📚', label: 'Reading'),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ===== Small components =====

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? kPrimaryPurple : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? kPrimaryPurple : const Color(0xFFDDDDDD),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : const Color(0xFF555555),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String emoji;
  final String label;

  const _RecommendationCard({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    final width =
        (MediaQuery.of(context).size.width - 18 * 2 - 12) / 2; // match padding

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2A0B38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
