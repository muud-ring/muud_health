// models/TrendsDashboard.js
const mongoose = require('mongoose');

const DayScoreSchema = new mongoose.Schema(
  {
    date: Date,
    score: Number, // -1 to 1 or 0..1
  },
  { _id: false }
);

const TimelineEntrySchema = new mongoose.Schema(
  {
    date: Date,
    completed: Number,
    skipped: Number,
  },
  { _id: false }
);

const PieSliceSchema = new mongoose.Schema(
  {
    label: String,
    percent: Number,
  },
  { _id: false }
);

const MoodPointSchema = new mongoose.Schema(
  {
    time: String,
    mood: String,
    color: String,
  },
  { _id: false }
);

const CalendarDaySchema = new mongoose.Schema(
  {
    date: Date,
    logged: { type: Boolean, default: false },
  },
  { _id: false }
);

const LeaderSchema = new mongoose.Schema(
  {
    name: String,
    points: Number,
    rank: Number,
    avatarUrl: String,
  },
  { _id: false }
);

const TrendsDashboardSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },

    // 0. Daily Snapshot
    dailySnapshot: {
      journalsLogged: { type: Number, default: 0 },
      journeysCompleted: { type: Number, default: 0 },
      avgHeartRate: { type: Number, default: 0 },
      stressLevel: { type: String, default: 'Unknown' },
    },

    // 1. Mood Summary
    moodSummary: {
      todayMood: { type: String, default: 'Neutral' }, // e.g. 'Happy'
      emoji: { type: String, default: '😶' },
      timeline: [MoodPointSchema], // mini mood points during day
      note: { type: String, default: '' },
    },

    // 2. Streak & Milestone Tracker
    streaks: {
      currentStreak: { type: Number, default: 0 },
      longestStreak: { type: Number, default: 0 },
      calendar: [CalendarDaySchema], // days user logged/journaled
    },

    // 3. Top Emotional Tags
    topTags: [{ type: String }],

    // 4. Sentiment Arc Chart
    sentimentArc: {
      range: { type: String, default: 'last_7_days' },
      days: [DayScoreSchema],
      note: { type: String, default: '' },
    },

    // 5. Journaling Trends
    journalingTrends: {
      daysJournaling: { type: Number, default: 0 },
      toneChangePercent: { type: Number, default: 0 }, // +20, -10 etc
      topTags: [{ type: String }],
    },

    // 6. Wellness Journey Trends
    wellnessJourney: {
      pie: [PieSliceSchema], // e.g. [{label:'Mindfulness',percent:60}, ...]
      timeline: [TimelineEntrySchema],
    },

    // 7. Community Engagement Trends
    communityTrends: {
      supportReactions: { type: Number, default: 0 },
      mostEngagedJournal: { type: String, default: '' },
      mostEngagedJourney: { type: String, default: '' },
    },

    // Leaderboard
    leaderboard: [LeaderSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model('TrendsDashboard', TrendsDashboardSchema);
