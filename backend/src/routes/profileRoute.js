// backend/src/routes/profileRoute.js
const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');

const {
  getMyProfile,
  updateMyProfile,
  updateOnboarding,
} = require('../controllers/profileController');

router.get('/me', authMiddleware, getMyProfile);
router.patch('/me', authMiddleware, updateMyProfile);

// Onboarding-specific updates
router.put('/onboarding', authMiddleware, updateOnboarding);

module.exports = router;
