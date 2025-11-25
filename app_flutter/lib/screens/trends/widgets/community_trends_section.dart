// lib/screens/trends/widgets/community_trends_section.dart

import 'package:flutter/material.dart';
import '../trends_constants.dart';
import 'section_title.dart';
import 'package:app_flutter/models/trends/trends_dashboard.dart';

class CommunityTrendsSection extends StatelessWidget {
  final CommunityTrends community;
  final List<LeaderboardUser> leaderboard;

  const CommunityTrendsSection({
    super.key,
    required this.community,
    required this.leaderboard,
  });

  @override
  Widget build(BuildContext context) {
    final reactions = community.supportReactions;
    final journal = community.mostEngagedJournal.isEmpty
        ? 'a recent journal'
        : community.mostEngagedJournal;
    final journey = community.mostEngagedJourney.isEmpty
        ? 'a recent journey'
        : community.mostEngagedJourney;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Community Trends'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardLavender,
            borderRadius: BorderRadius.circular(kCardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your friends sent $reactions supportive reactions after your low mood entries.',
                style: const TextStyle(
                  color: kPrimaryPurple,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your most engaged journal was “$journal”, and your most engaged journey was “$journey”.',
                style: const TextStyle(color: kSubheadingColor, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle(title: 'Leaderboard'),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: leaderboard.isEmpty
              ? const Center(
                  child: Text(
                    'Your inner circle leaderboard will appear here.',
                    style: TextStyle(color: kSubheadingColor, fontSize: 12),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: leaderboard.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final item = leaderboard[index];
                    return _LeaderCard(leader: item);
                  },
                ),
        ),
      ],
    );
  }
}

class _LeaderCard extends StatelessWidget {
  final LeaderboardUser leader;

  const _LeaderCard({required this.leader});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kPrimaryPurple.withOpacity(0.4),
                    width: 3,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 34, color: kPrimaryPurple),
                ),
              ),
              Positioned(
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    '#${leader.rank}',
                    style: const TextStyle(
                      color: kPrimaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            leader.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kPrimaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '+${leader.points} pts',
            style: const TextStyle(color: kSubheadingColor, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
