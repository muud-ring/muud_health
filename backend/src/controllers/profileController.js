// backend/src/controllers/profileController.js

const User = require('../models/User');

// -----------------------------------------------------
// Helper: map User -> profile JSON that Flutter expects
// -----------------------------------------------------
const buildProfileResponse = (user) => ({
  user: {
    id: user._id,
    fullName: user.fullName || '',
    username: user.username || '',
    bio: user.bio || '',
    location: user.location || '',
    phone: user.phone || '',
    email: user.email || '',
    mood: user.mood || '',
    avatarUrl: user.avatarUrl || '',
  },
});

// -----------------------------------------------------
// GET /api/profile/me
// -----------------------------------------------------
exports.getMyProfile = async (req, res) => {
  try {
    // req.userId is set by authMiddleware
    const user = await User.findById(req.userId);

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.json(buildProfileResponse(user));
  } catch (err) {
    console.error('getMyProfile error:', err);
    return res.status(500).json({ message: 'Error fetching profile.' });
  }
};

// -----------------------------------------------------
// PATCH /api/profile/me
// -----------------------------------------------------
exports.updateMyProfile = async (req, res) => {
  try {
    // Only allow specific fields to be updated from the app
    const allowedFields = [
      'fullName',
      'username',
      'bio',
      'location',
      'phone',
      'mood',
      'avatarUrl',
    ];

    const updates = {};
    for (const field of allowedFields) {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    }

    const user = await User.findByIdAndUpdate(req.userId, updates, {
      new: true,
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.json(buildProfileResponse(user));
  } catch (err) {
    console.error('updateMyProfile error:', err);
    return res.status(500).json({ message: 'Error updating profile.' });
  }
};

// -----------------------------------------------------
// PUT /api/profile/onboarding
// (you can expand this later for onboarding fields)
// -----------------------------------------------------
exports.updateOnboarding = async (req, res) => {
  try {
    // For now, we just allow arbitrary onboarding data under "onboarding"
    // Adjust this to match your User schema when you finalize onboarding.
    const updates = {};

    if (req.body.onboarding !== undefined) {
      updates.onboarding = req.body.onboarding;
    }

    const user = await User.findByIdAndUpdate(req.userId, updates, {
      new: true,
    });

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    return res.json(buildProfileResponse(user));
  } catch (err) {
    console.error('updateOnboarding error:', err);
    return res.status(500).json({ message: 'Error updating onboarding.' });
  }
};
