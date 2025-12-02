// backend/src/models/User.js

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema(
  {
    fullName: {
      type: String,
      required: true,
    },

    username: {
      type: String,
      required: true,
      unique: true,
      trim: true,
    },

    email: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },

    phone: {
      type: String,
      unique: true,
      sparse: true,
      trim: true,
    },

    password: {
      type: String,
      required: true,
      minlength: 8,
    },

    dateOfBirth: {
      type: Date,
      required: true,
    },

    isVerified: {
      type: Boolean,
      default: false,
    },
    verificationOtp: {
      type: String,
    },
    verificationOtpExpiresAt: {
      type: Date,
    },

    bio: {
      type: String,
      default: '',
    },
    location: {
      type: String,
      default: '',
    },
    mood: {
      type: String,
      default: '',
    },
    avatarUrl: {
      type: String,
      default: '',
    },

    // 🔹 Nested onboarding object (single source of truth)
    onboarding: {
      // Screen: "Is there anything specific you’d like to focus on?"
      focus: {
        type: String,
        enum: [
          'Improve mood',
          'Increase focus and productivity',
          'Self-improvement',
          'Reduce stress or anxiety',
          'Other',
        ],
        default: null,
      },

      // Screen: "Pick your favorite color"
      favoriteColor: {
        type: String, // e.g. "#9A29CF"
        default: null,
      },

      // Screen: "Do you have any preferred types of activities?"
      activities: [
        {
          type: String,
          enum: [
            'Meditation',
            'Exercise',
            'Reading',
            'Cooking',
            'Social',
            'Pet care',
          ],
        },
      ],

      // Screen: "MUUD wants to send you notifications"
      notificationsEnabled: {
        type: Boolean, // true = allow, false = no thanks
        default: null,
      },

      // Screen 6: "Here’s how MUUD Health can support you"
      // We store keys like: "navigate_emotions", "uncover_patterns", "wellness_sessions"
      supportOptions: [
        {
          type: String,
        },
      ],

      // Screen 7: first MUUD check-in
      // Flutter sends: "happy","fear","dislike","sadness","angry","surprised"
      initialMood: {
        type: String,
        enum: ['happy', 'fear', 'dislike', 'sadness', 'angry', 'surprised'],
        default: null,
      },

      // Screen 8: "Just a moment while we get MUUD ready for you…"
      // Flutter sends: "customize_journal","prepare_sessions","create_optimal_plan"
      preparingChoice: {
        type: String,
        enum: [
          'customize_journal',
          'prepare_sessions',
          'create_optimal_plan',
        ],
        default: null,
      },

      completed: {
        type: Boolean,
        default: false,
      },
      completedAt: {
        type: Date,
      },
    },
  },
  { timestamps: true }
);

// Hash password before saving, ONLY here
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
