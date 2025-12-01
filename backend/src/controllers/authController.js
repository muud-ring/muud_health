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

    if (!mobileOrEmail || !fullName || !username || !password || !dateOfBirth) {
      return res.status(400).json({ message: 'Please fill in all fields.' });
    }

    const passwordRegex = /^(?=.*\d)(?=.*[!@#$%^&*?])[A-Za-z\d!@#$%^&*?]{8,}$/;

    if (!passwordRegex.test(password)) {
      return res.status(400).json({
        message:
          'Password must be at least 8 characters long and include at least 1 number and 1 special character.',
      });
    }

    const dobDate = new Date(dateOfBirth);
    if (isNaN(dobDate.getTime())) {
      return res.status(400).json({ message: 'Invalid date of birth.' });
    }

    const cleanUsername = username.trim();
    const existingUsername = await User.findOne({ username: cleanUsername });
    if (existingUsername) {
      return res.status(400).json({ message: 'Username already taken.' });
    }

    let email = null;
    let phone = null;

    const trimmed = mobileOrEmail.trim();
    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (emailPattern.test(trimmed)) {
      email = trimmed.toLowerCase();
      const existingEmail = await User.findOne({ email });
      if (existingEmail) {
        return res.status(400).json({ message: 'Email already in use.' });
      }
    } else {
      phone = trimmed;
      const existingPhone = await User.findOne({ phone });
      if (existingPhone) {
        return res.status(400).json({ message: 'Phone already in use.' });
      }
    }

    // 🚨 No manual bcrypt here – plain password goes in
    const userData = {
      fullName,
      username: cleanUsername,
      password,            // plain; gets hashed in pre-save hook
      dateOfBirth: dobDate,
    };

    if (email) userData.email = email;
    if (phone) userData.phone = phone;

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

// @desc    Login user with email OR phone OR username
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { identifier, password } = req.body; // identifier = email / phone / username

    if (!identifier || !password) {
      return res
        .status(400)
        .json({ message: 'Please provide email/phone/username and password.' });
    }

    const trimmed = identifier.trim();
    const lower = trimmed.toLowerCase();

    const user = await User.findOne({
      $or: [
        { email: lower },
        { phone: trimmed },
        { username: trimmed },
      ],
    });

    if (!user) {
      console.log('LOGIN: no user for identifier', identifier);
      return res.status(400).json({ message: 'Invalid credentials.' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    console.log('LOGIN: password match?', isMatch);

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
