// backend/src/routes/peopleRoute.js
const express = require("express");
const router = express.Router();

const authMiddleware = require("../middleware/authMiddleware");
const {
  listPeople,
  getPersonProfile,
} = require("../controllers/peopleController");

router.get("/", authMiddleware, listPeople);
router.get("/:id", authMiddleware, getPersonProfile);

module.exports = router;
