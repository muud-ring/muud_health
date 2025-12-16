const express = require("express");
const router = express.Router();

const { getUploadUrl } = require("../controllers/s3Controller");
const authMiddleware = require("../middleware/authMiddleware");

router.post("/upload-url", authMiddleware, getUploadUrl);

module.exports = router;
