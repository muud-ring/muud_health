// backend/src/routes/authRoute.js

const express = require('express');
const router = express.Router();

// Import functions directly from authController
const {
  signup,
  login,
  oauthGoogle,
  appleLogin,
  facebookLogin,
} = require('../controllers/authController');

// ---------- AUTH ROUTES ----------

// Normal signup & login
router.post('/signup', signup);
router.post('/login', login);

// Google OAuth login
router.post('/google', oauthGoogle);

// Apple Sign-In
router.post('/apple', appleLogin);

// Facebook Login
router.post('/facebook', facebookLogin);

module.exports = router;
