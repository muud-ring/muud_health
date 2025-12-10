// controllers/authController.js

const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');

// GOOGLE OAUTH CLIENT
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// -----------------------------------------------------
// Signup Controller
// -----------------------------------------------------
exports.signup = async (req, res) => {
  try {
    const { fullName, email, phone, password, dateOfBirth } = req.body;

    let existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already in use.' });
    }

    const hashed = await bcrypt.hash(password, 10);

    const user = new User({
      fullName,
      email,
      phone,
      password: hashed,
      dateOfBirth,
    });

    await user.save();

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: '7d',
    });
    
    res.json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
      },
    });
    
  } catch (err) {
    console.error('Signup Error:', err);
    res.status(500).json({ message: 'Signup failed.' });
  }
};

// -----------------------------------------------------
// Login Controller
// -----------------------------------------------------
exports.login = async (req, res) => {
  try {
    const { emailOrPhone, password } = req.body;

    const user = await User.findOne({
      $or: [{ email: emailOrPhone }, { phone: emailOrPhone }],
    }).select('+password');

    if (!user) {
      return res.status(400).json({ message: 'User not found.' });
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      return res.status(400).json({ message: 'Invalid password.' });
    }

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, {
      expiresIn: '7d',
    });

    res.json({ token });
  } catch (err) {
    console.error('Login Error:', err);
    res.status(500).json({ message: 'Login failed.' });
  }
};

// -----------------------------------------------------
// Get Profile
// -----------------------------------------------------
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.userId);

    if (!user) return res.status(404).json({ message: 'User not found.' });

    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Error fetching profile.' });
  }
};

// -----------------------------------------------------
// GOOGLE OAUTH LOGIN
// -----------------------------------------------------
// ---------- GOOGLE OAUTH LOGIN ----------
exports.oauthGoogle = async (req, res) => {
  try {
    const { idToken } = req.body;

    if (!idToken) {
      return res.status(400).json({ message: 'idToken is required' });
    }

    // 1) Verify token with Google
    const ticket = await googleClient.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    const googleUserId = payload.sub; // Google’s unique user id
    const email = payload.email;
    const fullName = payload.name || 'Google User';

    // Build a default username from email (before @)
    let generatedUsername = '';
    if (email) {
      generatedUsername = email.split('@')[0];
    } else {
      generatedUsername = `google_${googleUserId.slice(0, 6)}`;
    }

    // 2) Find existing user (by provider id or email)
    let user = await User.findOne({
      $or: [
        { oauthProvider: 'google', oauthProviderId: googleUserId },
        { email },
      ],
    });

    // 3) If no user, create one
    if (!user) {
      user = new User({
        fullName,
        email,
        username: generatedUsername,   // <--- set username for schema
        oauthProvider: 'google',
        oauthProviderId: googleUserId,
        emailVerified: true,
        // dateOfBirth is optional; will be filled via onboarding
      });

      await user.save();
    }

    // 4) Create JWT just like normal login
    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    // 5) Respond to Flutter
    res.json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        username: user.username,
      },
    });
  } catch (err) {
    console.error('Google OAuth Error:', err);
    return res.status(401).json({ message: 'Google login failed' });
  }
};
