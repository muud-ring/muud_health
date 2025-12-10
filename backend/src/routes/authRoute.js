// backend/src/routes/authRoute.js

const express = require('express');
const router = express.Router();

const {
  signup,
  login,
  getProfile,
  oauthGoogle,
} = require('../controllers/authController');

// Email / password auth
router.post('/signup', signup);
router.post('/login', login);

// Google OAuth
router.post('/oauth/google', oauthGoogle);

// (Optional) profile route WITHOUT auth middleware for now
// You can protect it later once we hook up the auth middleware correctly.
router.get('/profile', getProfile);

module.exports = router;
