const mongoose = require("mongoose");
const Conversation = require("../models/Conversation");
const Message = require("../models/Message");

// POST /api/chats/conversations
// body: { otherUserId }
exports.createOrGetConversation = async (req, res) => {
  try {
    const userId = req.userId;
    const { otherUserId } = req.body;

    if (!otherUserId) {
      return res.status(400).json({ message: "otherUserId is required" });
    }

    if (!mongoose.Types.ObjectId.isValid(otherUserId)) {
      return res.status(400).json({ message: "Invalid otherUserId" });
    }

    const participants = [userId, otherUserId].sort(); // stable order

    let convo = await Conversation.findOne({ participants });

    if (!convo) {
      convo = await Conversation.create({ participants });
    }

    return res.json({ conversation: convo });
  } catch (err) {
    console.error("createOrGetConversation error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// POST /api/chats/messages
// body: { conversationId, text }
exports.sendMessage = async (req, res) => {
  try {
    const userId = req.userId;
    const { conversationId, text } = req.body;

    if (!conversationId) {
      return res.status(400).json({ message: "conversationId is required" });
    }

    if (!mongoose.Types.ObjectId.isValid(conversationId)) {
      return res.status(400).json({ message: "Invalid conversationId" });
    }

    if (!text || !text.trim()) {
      return res.status(400).json({ message: "text is required" });
    }

    const convo = await Conversation.findById(conversationId);
    if (!convo) return res.status(404).json({ message: "Conversation not found" });

    // ensure sender is part of convo
    const isMember = convo.participants.some((p) => p.toString() === userId);
    if (!isMember) return res.status(403).json({ message: "Not allowed" });

    const msg = await Message.create({
      conversationId,
      senderId: userId,
      text: text.trim(),
    });

    convo.lastMessage = msg.text;
    await convo.save();

    return res.json({ message: msg });
  } catch (err) {
    console.error("sendMessage error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

// GET /api/chats/conversations/:id/messages
exports.getMessages = async (req, res) => {
  try {
    const userId = req.userId;
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(400).json({ message: "Invalid conversation id" });
    }

    const convo = await Conversation.findById(id);
    if (!convo) return res.status(404).json({ message: "Conversation not found" });

    const isMember = convo.participants.some((p) => p.toString() === userId);
    if (!isMember) return res.status(403).json({ message: "Not allowed" });

    const messages = await Message.find({ conversationId: id })
      .sort({ createdAt: 1 })
      .limit(200);

    return res.json({ messages });
  } catch (err) {
    console.error("getMessages error:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

exports.getMyConversations = async (req, res) => {
  try {
    const myId = req.user.id;

    const conversations = await Conversation.find({
      participants: myId,
    })
      .populate("participants", "fullName profileImage avatar imageUrl email") // adjust fields if needed
      .sort({ lastMessageAt: -1, updatedAt: -1 });

    // Build "other user" for 1-1 chats
    const formatted = conversations.map((c) => {
      const other =
        c.participants.find((p) => String(p._id) !== String(myId)) ||
        c.participants[0];

      return {
        _id: c._id,
        otherUser: other
          ? {
              _id: other._id,
              fullName: other.fullName || "User",
              avatar:
                other.profileImage || other.avatar || other.imageUrl || "",
              email: other.email || "",
            }
          : null,
        lastMessageText: c.lastMessageText || "",
        lastMessageAt: c.lastMessageAt,
        lastMessageSender: c.lastMessageSender,
      };
    });

    return res.json({ conversations: formatted });
  } catch (err) {
    console.error("getMyConversations error:", err);
    return res.status(500).json({ error: "Failed to load conversations" });
  }
};
