// lib/models/trends/trends_dashboard.dart

class TrendsDashboard {
  final DailySnapshot dailySnapshot;
  final MoodSummary moodSummary;
  final Streaks streaks;
  final List<String> topTags;
  final SentimentArc sentimentArc;
  final JournalingTrends journalingTrends;
  final WellnessJourney wellnessJourney;
  final CommunityTrends communityTrends;
  final List<LeaderboardUser> leaderboard;

  TrendsDashboard({
    required this.dailySnapshot,
    required this.moodSummary,
    required this.streaks,
    required this.topTags,
    required this.sentimentArc,
    required this.journalingTrends,
    required this.wellnessJourney,
    required this.communityTrends,
    required this.leaderboard,
  });

  factory TrendsDashboard.fromJson(Map<String, dynamic> json) {
    return TrendsDashboard(
      dailySnapshot: DailySnapshot.fromJson(json['dailySnapshot']),
      moodSummary: MoodSummary.fromJson(json['moodSummary']),
      streaks: Streaks.fromJson(json['streaks']),
      topTags: List<String>.from(json['topTags'] ?? []),
      sentimentArc: SentimentArc.fromJson(json['sentimentArc']),
      journalingTrends: JournalingTrends.fromJson(json['journalingTrends']),
      wellnessJourney: WellnessJourney.fromJson(json['wellnessJourney']),
      communityTrends: CommunityTrends.fromJson(json['communityTrends']),
      leaderboard: (json['leaderboard'] as List)
          .map((e) => LeaderboardUser.fromJson(e))
          .toList(),
    );
  }
}

// ------------------------------------------------------------
// DAILY SNAPSHOT
// ------------------------------------------------------------

class DailySnapshot {
  final int journalsLogged;
  final int journeysCompleted;
  final int avgHeartRate;
  final String stressLevel;

  DailySnapshot({
    required this.journalsLogged,
    required this.journeysCompleted,
    required this.avgHeartRate,
    required this.stressLevel,
  });

  factory DailySnapshot.fromJson(Map<String, dynamic> json) {
    return DailySnapshot(
      journalsLogged: json['journalsLogged'] ?? 0,
      journeysCompleted: json['journeysCompleted'] ?? 0,
      avgHeartRate: json['avgHeartRate'] ?? 0,
      stressLevel: json['stressLevel'] ?? '',
    );
  }
}

// ------------------------------------------------------------
// MOOD SUMMARY
// ------------------------------------------------------------

class MoodSummary {
  final String todayMood;
  final String emoji;
  final List<MoodPoint> timeline;
  final String note;

  MoodSummary({
    required this.todayMood,
    required this.emoji,
    required this.timeline,
    required this.note,
  });

  factory MoodSummary.fromJson(Map<String, dynamic> json) {
    return MoodSummary(
      todayMood: json['todayMood'] ?? '',
      emoji: json['emoji'] ?? '',
      timeline: (json['timeline'] as List)
          .map((e) => MoodPoint.fromJson(e))
          .toList(),
      note: json['note'] ?? '',
    );
  }
}

class MoodPoint {
  final String time;
  final String mood;
  final String color;

  MoodPoint({required this.time, required this.mood, required this.color});

  factory MoodPoint.fromJson(Map<String, dynamic> json) {
    return MoodPoint(
      time: json['time'] ?? '',
      mood: json['mood'] ?? '',
      color: json['color'] ?? '',
    );
  }
}

// ------------------------------------------------------------
// STREAKS
// ------------------------------------------------------------

class Streaks {
  final int currentStreak;
  final int longestStreak;
  final List<CalendarDay> calendar;

  Streaks({
    required this.currentStreak,
    required this.longestStreak,
    required this.calendar,
  });

  factory Streaks.fromJson(Map<String, dynamic> json) {
    return Streaks(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      calendar: (json['calendar'] as List)
          .map((e) => CalendarDay.fromJson(e))
          .toList(),
    );
  }
}

class CalendarDay {
  final DateTime date;
  final bool logged;

  CalendarDay({required this.date, required this.logged});

  factory CalendarDay.fromJson(Map<String, dynamic> json) {
    return CalendarDay(
      date: DateTime.parse(json['date']),
      logged: json['logged'] ?? false,
    );
  }
}

// ------------------------------------------------------------
// SENTIMENT ARC
// ------------------------------------------------------------

class SentimentArc {
  final String range;
  final List<SentimentDay> days;
  final String note;

  SentimentArc({required this.range, required this.days, required this.note});

  factory SentimentArc.fromJson(Map<String, dynamic> json) {
    return SentimentArc(
      range: json['range'] ?? '',
      days: (json['days'] as List)
          .map((e) => SentimentDay.fromJson(e))
          .toList(),
      note: json['note'] ?? '',
    );
  }
}

class SentimentDay {
  final DateTime date;
  final double score;

  SentimentDay({required this.date, required this.score});

  factory SentimentDay.fromJson(Map<String, dynamic> json) {
    return SentimentDay(
      date: DateTime.parse(json['date']),
      score: (json['score'] ?? 0).toDouble(),
    );
  }
}

// ------------------------------------------------------------
// JOURNALING TRENDS
// ------------------------------------------------------------

class JournalingTrends {
  final int daysJournaling;
  final int toneChangePercent;
  final List<String> topTags;

  JournalingTrends({
    required this.daysJournaling,
    required this.toneChangePercent,
    required this.topTags,
  });

  factory JournalingTrends.fromJson(Map<String, dynamic> json) {
    return JournalingTrends(
      daysJournaling: json['daysJournaling'] ?? 0,
      toneChangePercent: json['toneChangePercent'] ?? 0,
      topTags: List<String>.from(json['topTags'] ?? []),
    );
  }
}

// ------------------------------------------------------------
// WELLNESS JOURNEY
// ------------------------------------------------------------

class WellnessJourney {
  final List<PieSlice> pie;
  final List<JourneyTimelineEntry> timeline;

  WellnessJourney({required this.pie, required this.timeline});

  factory WellnessJourney.fromJson(Map<String, dynamic> json) {
    return WellnessJourney(
      pie: (json['pie'] as List).map((e) => PieSlice.fromJson(e)).toList(),
      timeline: (json['timeline'] as List)
          .map((e) => JourneyTimelineEntry.fromJson(e))
          .toList(),
    );
  }
}

class PieSlice {
  final String label;
  final int percent;

  PieSlice({required this.label, required this.percent});

  factory PieSlice.fromJson(Map<String, dynamic> json) {
    return PieSlice(label: json['label'] ?? '', percent: json['percent'] ?? 0);
  }
}

class JourneyTimelineEntry {
  final DateTime date;
  final int completed;
  final int skipped;

  JourneyTimelineEntry({
    required this.date,
    required this.completed,
    required this.skipped,
  });

  factory JourneyTimelineEntry.fromJson(Map<String, dynamic> json) {
    return JourneyTimelineEntry(
      date: DateTime.parse(json['date']),
      completed: json['completed'] ?? 0,
      skipped: json['skipped'] ?? 0,
    );
  }
}

// ------------------------------------------------------------
// COMMUNITY TRENDS + LEADERBOARD
// ------------------------------------------------------------

class CommunityTrends {
  final int supportReactions;
  final String mostEngagedJournal;
  final String mostEngagedJourney;

  CommunityTrends({
    required this.supportReactions,
    required this.mostEngagedJournal,
    required this.mostEngagedJourney,
  });

  factory CommunityTrends.fromJson(Map<String, dynamic> json) {
    return CommunityTrends(
      supportReactions: json['supportReactions'] ?? 0,
      mostEngagedJournal: json['mostEngagedJournal'] ?? '',
      mostEngagedJourney: json['mostEngagedJourney'] ?? '',
    );
  }
}

class LeaderboardUser {
  final String name;
  final int points;
  final int rank;
  final String avatarUrl;

  LeaderboardUser({
    required this.name,
    required this.points,
    required this.rank,
    required this.avatarUrl,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
