// backend/src/controllers/profileController.js
const User = require('../models/User');

// GET /api/profile/me
exports.getMyProfile = async (req, res) => {
  try {
    const userId = req.user.id; // from authMiddleware (decoded token)

    const user = await User.findById(userId).select(
      'fullName username email phone dateOfBirth bio location mood avatarUrl onboarding'
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({ user });
  } catch (err) {
    console.error('getMyProfile error:', err);
    res.status(500).json({ message: 'Server error.' });
  }
};

// PATCH /api/profile/me
exports.updateMyProfile = async (req, res) => {
  try {
    const userId = req.user.id;

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
    allowedFields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updates[field] = req.body[field];
      }
    });

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updates },
      { new: true, runValidators: true }
    ).select(
      'fullName username email phone dateOfBirth bio location mood avatarUrl onboarding'
    );

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    res.json({ user });
  } catch (err) {
    console.error('updateMyProfile error:', err);
    res.status(500).json({ message: 'Server error.' });
  }
};

// 🔹 PUT /api/profile/onboarding
// Used by all onboarding screens to update User.onboarding
exports.updateOnboarding = async (req, res) => {
  try {
    const userId = req.user.id;

    const {
      focus,
      favoriteColor,
      activities,
      notificationsEnabled,
      supportOptions,
      initialMood,
      preparingChoice,
      completed,
    } = req.body;

    const update = {};

    if (focus !== undefined) {
      update['onboarding.focus'] = focus;
    }
    if (favoriteColor !== undefined) {
      update['onboarding.favoriteColor'] = favoriteColor;
    }
    if (Array.isArray(activities)) {
      update['onboarding.activities'] = activities;
    }
    if (notificationsEnabled !== undefined) {
      update['onboarding.notificationsEnabled'] = notificationsEnabled;
    }
    if (Array.isArray(supportOptions)) {
      update['onboarding.supportOptions'] = supportOptions;
    }
    if (initialMood !== undefined) {
      update['onboarding.initialMood'] = initialMood;
    }
    if (preparingChoice !== undefined) {
      update['onboarding.preparingChoice'] = preparingChoice;
    }
    if (completed !== undefined) {
      update['onboarding.completed'] = completed;
      if (completed === true) {
        update['onboarding.completedAt'] = new Date();
      }
    }

    if (Object.keys(update).length === 0) {
      return res
        .status(400)
        .json({ success: false, message: 'No onboarding fields provided' });
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: update },
      { new: true, runValidators: true }
    ).select(
      'fullName username email phone dateOfBirth bio location mood avatarUrl onboarding'
    );

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: 'User not found.' });
    }

    return res.json({
      success: true,
      message: 'Onboarding updated',
      user,
    });
  } catch (err) {
    console.error('updateOnboarding error:', err);
    res.status(500).json({
      success: false,
      message: 'Server error updating onboarding data.',
    });
  }
};
