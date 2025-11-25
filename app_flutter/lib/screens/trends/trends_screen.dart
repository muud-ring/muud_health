// lib/screens/trends/trends_screen.dart

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/token_storage.dart';
import '../../models/trends/trends_dashboard.dart';

import 'trends_constants.dart';
import 'widgets/trends_search_bar.dart';
import 'widgets/daily_snapshot_section.dart';
import 'widgets/mood_summary_section.dart';
import 'widgets/streaks_section.dart';
import 'widgets/top_tags_section.dart';
import 'widgets/sentiment_arc_section.dart';
import 'widgets/journaling_trends_section.dart';
import 'widgets/wellness_journey_section.dart';
import 'widgets/community_trends_section.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  late Future<TrendsDashboard?> _trendsFuture;

  @override
  void initState() {
    super.initState();
    _trendsFuture = _loadTrends();
  }

  Future<TrendsDashboard?> _loadTrends() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      print('No token found when loading trends');
      return null;
    }

    final data = await ApiService.getTrendsDashboard(token);
    if (data == null) return null;

    try {
      return TrendsDashboard.fromJson(data);
    } catch (e) {
      print('Error parsing TrendsDashboard: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TrendsDashboard?>(
      future: _trendsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimaryPurple),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Something went wrong loading your trends.',
              style: TextStyle(
                color: kPrimaryPurple,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final dashboard = snapshot.data;
        if (dashboard == null) {
          return const Center(
            child: Text(
              'No trends data available yet.',
              style: TextStyle(
                color: kPrimaryPurple,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        // All widgets below now receive real data models
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const TrendsSearchBar(),
              const SizedBox(height: 24),

              DailySnapshotSection(snapshot: dashboard.dailySnapshot),
              const SizedBox(height: 24),

              MoodSummarySection(moodSummary: dashboard.moodSummary),
              const SizedBox(height: 24),

              StreaksSection(streaks: dashboard.streaks),
              const SizedBox(height: 24),

              TopTagsSection(tags: dashboard.topTags),
              const SizedBox(height: 24),

              SentimentArcSection(sentimentArc: dashboard.sentimentArc),
              const SizedBox(height: 24),

              JournalingTrendsSection(trends: dashboard.journalingTrends),
              const SizedBox(height: 24),

              WellnessJourneySection(journey: dashboard.wellnessJourney),
              const SizedBox(height: 24),

              CommunityTrendsSection(
                community: dashboard.communityTrends,
                leaderboard: dashboard.leaderboard,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
