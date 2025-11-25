// backend/src/controllers/profileController.js
const User = require('../models/User');

// GET /api/profile/me
exports.getMyProfile = async (req, res) => {
  try {
    const userId = req.user.id; // from authMiddleware (decoded token)

    const user = await User.findById(userId).select(
      'fullName username email phone dateOfBirth bio location mood avatarUrl'
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
      'fullName username email phone dateOfBirth bio location mood avatarUrl'
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
