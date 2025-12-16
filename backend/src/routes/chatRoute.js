const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const chatController = require("../controllers/chatController");

router.post("/conversations", authMiddleware, chatController.createOrGetConversation);
router.post("/messages", authMiddleware, chatController.sendMessage);
router.get("/conversations/:id/messages", authMiddleware, chatController.getMessages);
router.get("/conversations", authMiddleware, chatController.getMyConversations);

module.exports = router;
