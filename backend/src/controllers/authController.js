// backend/src/controllers/authController.js

const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

// @desc    Register a new user (Sign Up)
// @route   POST /api/auth/signup
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { mobileOrEmail, fullName, username, password, dateOfBirth } = req.body;

    // Required fields
    if (!mobileOrEmail || !fullName || !username || !password || !dateOfBirth) {
      return res.status(400).json({ message: 'Please fill in all fields.' });
    }

    // Password validation
    const passwordRegex = /^(?=.*\d)(?=.*[!@#$%^&*?])[A-Za-z\d!@#$%^&*?]{8,}$/;

    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        message:
          'Password must be at least 8 characters long and include at least 1 number and 1 special character.',
      });
    }

    // Parse date
    const dobDate = new Date(dateOfBirth);
    if (isNaN(dobDate.getTime())) {
      return res.status(400).json({ message: 'Invalid date of birth.' });
    }

    // Check username uniqueness
    const existingUsername = await User.findOne({ username: username.trim() });
    if (existingUsername) {
      return res.status(400).json({ message: 'Username already taken.' });
    }

    // -----------------------------------------
    // Decide if user typed email or phone
    // -----------------------------------------
    let email = null;
    let phone = null;

    const trimmed = mobileOrEmail.trim();
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (emailPattern.test(trimmed)) {
      // treat as email
      email = trimmed.toLowerCase();

      const existingEmail = await User.findOne({ email });
      if (existingEmail) {
        return res.status(400).json({ message: 'Email already in use.' });
      }
    } else {
      // treat as phone
      phone = trimmed;

      const existingPhone = await User.findOne({ phone });
      if (existingPhone) {
        return res.status(400).json({ message: 'Phone already in use.' });
      }
    }

    // -----------------------------------------
    // Hash password
    // -----------------------------------------
    const hashedPassword = await bcrypt.hash(password, 10);

    // -----------------------------------------
    // Build user data WITHOUT nulls
    // -----------------------------------------
    const userData = {
      fullName,
      username: username.trim(),
      password: hashedPassword,
      dateOfBirth: dobDate,
    };

    if (email) userData.email = email;   // only set if not null
    if (phone) userData.phone = phone;   // only set if not null

    const user = await User.create(userData);

    return res.status(201).json({
      success: true,
      token: generateToken(user._id),
      user: {
        _id: user._id,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
      },
    });
  } catch (error) {
    console.error('Error in registerUser:', error);

    if (error.code === 11000) {
      const field = Object.keys(error.keyValue)[0];
      return res.status(400).json({
        message: `${field.charAt(0).toUpperCase() + field.slice(1)} already in use.`,
      });
    }

    return res.status(500).json({ message: 'Server error.' });
  }
};

// @desc    Login user with email OR phone
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { identifier, password } = req.body; // identifier = email OR phone

    if (!identifier || !password) {
      return res
        .status(400)
        .json({ message: 'Please provide email/phone and password.' });
    }

    const trimmed = identifier.trim();
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    let user;

    if (emailPattern.test(trimmed)) {
      user = await User.findOne({ email: trimmed.toLowerCase() });
    } else {
      user = await User.findOne({ phone: trimmed });
    }

    if (!user) {
      return res.status(400).json({ message: 'Invalid credentials.' });
    }

    // Compare password using bcrypt
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials.' });
    }

    return res.json({
      success: true,
      token: generateToken(user._id),
      user: {
        _id: user._id,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
      },
    });
  } catch (error) {
    console.error('Error in loginUser:', error);
    return res.status(500).json({ message: 'Server error.' });
  }
};

module.exports = {
  registerUser,
  loginUser,
};