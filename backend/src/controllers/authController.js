// backend/src/controllers/authController.js

const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { sendOtpEmail } = require('../utils/emailService'); // NEW

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

    // Check username uniqueness (case-sensitive right now)
    const cleanUsername = username.trim();
    const existingUsername = await User.findOne({ username: cleanUsername });
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
    // Build user data WITHOUT manual hashing
    // (pre-save hook in User.js will hash once)
    // -----------------------------------------
    const userData = {
      fullName,
      username: cleanUsername,
      password,            // plain text; schema hook will hash this
      dateOfBirth: dobDate,
    };

    if (email) userData.email = email;
    if (phone) userData.phone = phone;

    let user = await User.create(userData);

    // -----------------------------------------
    // Generate and send verification OTP (email only for now)
    // -----------------------------------------
    if (email) {
      const otp = Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit

      user.verificationOtp = otp;
      user.verificationOtpExpiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 mins
      // don't re-run validators here, we only update OTP fields
      await user.save({ validateBeforeSave: false });

      try {
        await sendOtpEmail(user.email, otp);
        console.log(`Sent OTP ${otp} to ${user.email}`);
      } catch (err) {
        console.error('Error sending OTP email:', err);
        // we don't fail signup just because email failed
      }
    }

    return res.status(201).json({
      success: true,
      token: generateToken(user._id),
      otpSent: !!email,                           // NEW
      verificationChannel: email ? 'email' : 'phone', // NEW (for future SMS)
      user: {
        _id: user._id,
        fullName: user.fullName,
        username: user.username,
        email: user.email,
        phone: user.phone,
        dateOfBirth: user.dateOfBirth,
        isVerified: user.isVerified,             // NEW (from model)
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

    // We allow login by:
    // - email (case-insensitive)
    // - phone
    // - username
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

    // (Later we can enforce isVerified here if you want)
    // if (!user.isVerified) { ... }

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
        isVerified: user.isVerified,
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
