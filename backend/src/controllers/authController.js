// backend/src/controllers/authController.js

const User = require('../models/User');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { OAuth2Client } = require('google-auth-library');
const appleSignin = require('apple-signin-auth');
const fetch = require('node-fetch');

// GOOGLE OAUTH CLIENT
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

// -----------------------------------------------------
// Helper: create JWT token
// -----------------------------------------------------
const createToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: '7d' });
};

// -----------------------------------------------------
// Signup Controller
// -----------------------------------------------------
exports.signup = async (req, res) => {
  try {
    const {
      mobileOrEmail, // single field from Flutter
      fullName,
      username,
      password,
      dateOfBirth,
    } = req.body;

    if (!mobileOrEmail || !username || !fullName || !password) {
      return res
        .status(400)
        .json({ message: 'Missing required signup fields.' });
    }

    // Decide whether the input is an email or a phone number
    let email = null;
    let phone = null;

    if (mobileOrEmail.includes('@')) {
      email = mobileOrEmail.toLowerCase();
    } else {
      phone = mobileOrEmail;
    }

    // Check if email/phone already used
    const orConditions = [];
    if (email) orConditions.push({ email });
    if (phone) orConditions.push({ phone });

    if (orConditions.length > 0) {
      const existingUser = await User.findOne({ $or: orConditions });
      if (existingUser) {
        return res
          .status(400)
          .json({ message: 'Email or phone already in use.' });
      }
    }

    // Build user doc WITHOUT phone/email when they are null
// NOTE: Do NOT hash here because User model already hashes in pre('save')
const userData = {
  fullName,
  username,
  password, // raw password; model will hash it
  dateOfBirth,
};


    if (email) userData.email = email;
    if (phone) userData.phone = phone;

    // Create new user
    const user = new User(userData);
    await user.save();

    // Create JWT
    const token = createToken(user._id);

    return res.json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        username: user.username,
      },
    });
  } catch (err) {
    console.error('Signup Error:', err);

    // Handle duplicate key errors nicely
    if (err.code === 11000 && err.keyPattern) {
      if (err.keyPattern.email) {
        return res.status(400).json({ message: 'Email already in use.' });
      }
      if (err.keyPattern.phone) {
        return res.status(400).json({ message: 'Phone already in use.' });
      }
      if (err.keyPattern.username) {
        return res.status(400).json({ message: 'Username already in use.' });
      }
      return res.status(400).json({ message: 'Duplicate value.' });
    }

    return res.status(500).json({ message: 'Signup failed.' });
  }
};


// -----------------------------------------------------
// Login Controller
// -----------------------------------------------------
exports.login = async (req, res) => {
  try {
    let { emailOrPhone, password } = req.body;

if (emailOrPhone && emailOrPhone.includes('@')) {
  emailOrPhone = emailOrPhone.toLowerCase().trim();
} else if (emailOrPhone) {
  emailOrPhone = emailOrPhone.trim();
}

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

    const token = createToken(user._id);

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

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    // 👉 Shape that Flutter expects: { user: { ... } }
    return res.json({
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
  } catch (err) {
    console.error('Get profile error:', err);
    return res.status(500).json({ message: 'Error fetching profile.' });
  }
};


// -----------------------------------------------------
// GOOGLE OAUTH LOGIN
// -----------------------------------------------------
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

    // Build a default username from email or Google ID
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
        username: generatedUsername,
        oauthProvider: 'google',
        oauthProviderId: googleUserId,
        emailVerified: true,
      });

      await user.save();
    }

    // 4) Create JWT
    const token = createToken(user._id);

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

// ---------- APPLE SIGN-IN ----------
exports.appleLogin = async (req, res) => {
  const { idToken, fullName } = req.body;

  if (!idToken) {
    return res.status(400).json({ message: 'idToken is required.' });
  }

  try {
    // Verify the token with Apple
    const applePayload = await appleSignin.verifyIdToken(idToken, {
      audience: process.env.APPLE_CLIENT_ID,
      ignoreExpiration: false,
    });

    const appleId = applePayload.sub;   // unique Apple user id from Apple
    const email = applePayload.email;   // may be undefined on later logins

    if (!appleId) {
      return res.status(400).json({ message: 'Invalid Apple token (no sub).' });
    }

    // Find by appleId first
    let user = await User.findOne({ appleId });

    // If not found and email exists, try find by email to link accounts
    if (!user && email) {
      user = await User.findOne({ email });
    }

    // If still not found, create a new user
    if (!user) {
      const nameFromApple =
        fullName && fullName.trim().length > 0 ? fullName.trim() : 'Apple User';

      const generatedUsername = email
        ? email.split('@')[0]
        : `apple_${appleId.slice(0, 6)}`;

      user = await User.create({
        fullName: nameFromApple,
        email: email || undefined,
        username: generatedUsername,
        appleId,
        oauthProvider: 'apple',
        oauthProviderId: appleId,
        emailVerified: !!email,
      });
    } else {
      // Ensure appleId & oauthProvider are properly set on existing user
      let modified = false;

      if (!user.appleId) {
        user.appleId = appleId;
        modified = true;
      }

      if (!user.oauthProvider) {
        user.oauthProvider = 'apple';
        modified = true;
      }

      if (!user.oauthProviderId) {
        user.oauthProviderId = appleId;
        modified = true;
      }

      if (email && !user.email) {
        user.email = email;
        modified = true;
      }

      if (email && !user.emailVerified) {
        user.emailVerified = true;
        modified = true;
      }

      if (modified) {
        await user.save();
      }
    }

    // Create JWT token
    const token = createToken(user._id);

    return res.status(200).json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        username: user.username,
      },
    });
  } catch (err) {
    console.error('Apple login error:', err);
    return res.status(500).json({ message: 'Apple Sign-In failed.' });
  }
};

// ---------- FACEBOOK LOGIN ----------
exports.facebookLogin = async (req, res) => {
  const { accessToken } = req.body;

  if (!accessToken) {
    return res.status(400).json({ message: 'accessToken is required.' });
  }

  try {
    // 1) Verify token & get user info from Facebook Graph API
    const graphUrl =
      'https://graph.facebook.com/me?fields=id,name,email&access_token=' +
      encodeURIComponent(accessToken);

    const fbResponse = await fetch(graphUrl);
    const fbData = await fbResponse.json();

    // If token is invalid, Facebook returns an "error" object
    if (!fbResponse.ok || fbData.error || !fbData.id) {
      console.error('Facebook token error:', fbData.error || fbData);
      return res
        .status(400)
        .json({ message: 'Invalid Facebook access token.' });
    }

    const facebookId = fbData.id;
    const fullName = fbData.name || 'Facebook User';
    const email = fbData.email; // may be undefined if user hides email

    // 2) Try find user by facebookId
    let user = await User.findOne({ facebookId });

    // 3) If not found and email exists, try to find by email to link accounts
    if (!user && email) {
      user = await User.findOne({ email });
    }

    // 4) If still not found, create a new user
    if (!user) {
      const generatedUsername = email
        ? email.split('@')[0]
        : `fb_${facebookId.slice(0, 6)}`;

      user = await User.create({
        fullName,
        username: generatedUsername,
        email: email || undefined,
        facebookId,
        oauthProvider: 'facebook',
        oauthProviderId: facebookId,
        emailVerified: !!email,
        isVerified: true,
      });
    } else {
      // 5) Ensure fields are updated for existing user
      let modified = false;

      if (!user.facebookId) {
        user.facebookId = facebookId;
        modified = true;
      }

      if (!user.oauthProvider) {
        user.oauthProvider = 'facebook';
        modified = true;
      }

      if (!user.oauthProviderId) {
        user.oauthProviderId = facebookId;
        modified = true;
      }

      if (email && !user.email) {
        user.email = email;
        modified = true;
      }

      if (email && !user.emailVerified) {
        user.emailVerified = true;
        modified = true;
      }

      if (modified) {
        await user.save();
      }
    }

    // 6) Create JWT token
    const token = createToken(user._id);

    return res.status(200).json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        email: user.email,
        username: user.username,
      },
    });
  } catch (err) {
    console.error('Facebook login error:', err);
    return res.status(500).json({ message: 'Facebook login failed.' });
  }
};
