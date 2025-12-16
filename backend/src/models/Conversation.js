const mongoose = require("mongoose");

const conversationSchema = new mongoose.Schema(
  {
    participants: [
      { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    ],
    lastMessage: { type: String, default: "" },
  },
  { timestamps: true }
);

// Ensure same 2 users don’t create duplicate conversations
conversationSchema.index({ participants: 1 }, { unique: true });

module.exports = mongoose.model("Conversation", conversationSchema);
