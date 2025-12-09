// models/Journal.js

const mongoose = require('mongoose');

const journalSchema = new mongoose.Schema(
  {
    // Who created this journal
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },

    // For now this can be a placeholder or local path.
    // Later we'll store the S3 URL here.
    imageUrl: {
      type: String,
      default: '',
    },

    caption: {
      type: String,
      default: '',
      trim: true,
    },

    // Public / Inner Circle / Connections
    visibility: {
      type: String,
      enum: ['Public', 'Inner Circle', 'Connections'],
      default: 'Public',
    },

    // Main emoji / mood sticker (optional)
    emoji: {
      type: String,
      default: '',
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Journal', journalSchema);
