// controllers/trendController.js
const TrendsDashboard = require('../models/TrendsDashboard');

// Helper: default data to match your current UI
function buildDefaultDashboard(userId) {
  const now = new Date();

  return {
    user: userId,

    dailySnapshot: {
      journalsLogged: 30,
      journeysCompleted: 24,
      avgHeartRate: 72,
      stressLevel: 'Moderate',
    },

    moodSummary: {
      todayMood: 'Happy',
      emoji: '😊',
      timeline: [
        { time: '9 AM', mood: 'Calm', color: '#A5D6A7' },
        { time: '12 PM', mood: 'Focused', color: '#FFECB3' },
        { time: '6 PM', mood: 'Happy', color: '#FFD54F' },
      ],
      note: 'Your MUUD was positive overall this week.',
    },

    streaks: {
      currentStreak: 5,
      longestStreak: 7,
      calendar: [
        { date: now, logged: true },
      ],
    },

    topTags: ['#happy', '#grateful', '#hopeful', '#overwhelmed'],

    sentimentArc: {
      range: 'last_7_days',
      days: [
        { date: new Date(now.getTime() - 6 * 86400000), score: 0.2 },
        { date: new Date(now.getTime() - 5 * 86400000), score: 0.4 },
        { date: new Date(now.getTime() - 4 * 86400000), score: 0.7 },
        { date: new Date(now.getTime() - 3 * 86400000), score: 0.8 },
        { date: new Date(now.getTime() - 2 * 86400000), score: 0.5 },
        { date: new Date(now.getTime() - 1 * 86400000), score: 0.6 },
        { date: now, score: 0.9 },
      ],
      note: 'You’ve been trending more positive last week 🌟',
    },

    journalingTrends: {
      daysJournaling: 10,
      toneChangePercent: 20,
      topTags: ['#grateful', '#hopeful', '#calm'],
    },

    wellnessJourney: {
      pie: [
        { label: 'Mindfulness', percent: 60 },
        { label: 'Journaling', percent: 30 },
        { label: 'Fitness', percent: 10 },
      ],
      timeline: [
        { date: new Date(now.getTime() - 3 * 86400000), completed: 2, skipped: 1 },
        { date: new Date(now.getTime() - 2 * 86400000), completed: 3, skipped: 0 },
      ],
    },

    communityTrends: {
      supportReactions: 8,
      mostEngagedJournal: 'Sunday Reflection',
      mostEngagedJourney: '7-Day Calm Challenge',
    },

    leaderboard: [
      {
        name: 'Meghan Jes...',
        points: 40,
        rank: 2,
        avatarUrl: '',
      },
      {
        name: 'Bryan Wolf',
        points: 43,
        rank: 1,
        avatarUrl: '',
      },
      {
        name: 'Alex Turner',
        points: 38,
        rank: 3,
        avatarUrl: '',
      },
    ],
  };
}

// GET /api/trends/dashboard
const getTrendsDashboard = async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;

    let dashboard = await TrendsDashboard.findOne({ user: userId });

    if (!dashboard) {
      const defaults = buildDefaultDashboard(userId);
      dashboard = await TrendsDashboard.create(defaults);
    }

    res.json(dashboard);
  } catch (err) {
    console.error('Error in getTrendsDashboard:', err);
    res.status(500).json({ message: 'Server error fetching trends dashboard' });
  }
};

// PATCH /api/trends/dashboard
const updateTrendsDashboard = async (req, res) => {
  try {
    const userId = req.user.id || req.user._id;
    const updates = req.body || {};

    const dashboard = await TrendsDashboard.findOneAndUpdate(
      { user: userId },
      { $set: updates },
      { new: true, upsert: true }
    );

    res.json(dashboard);
  } catch (err) {
    console.error('Error in updateTrendsDashboard:', err);
    res.status(500).json({ message: 'Server error updating trends dashboard' });
  }
};

module.exports = {
  getTrendsDashboard,
  updateTrendsDashboard,
};
