// routes/journalRoute.js

const express = require('express');
const router = express.Router();

const authMiddleware = require('../middleware/authMiddleware');
const {
  createJournal,
  getMyJournals,
} = require('../controllers/journalController');

// All journal routes require a valid JWT
router.post('/', authMiddleware, createJournal);
router.get('/me', authMiddleware, getMyJournals);

module.exports = router;
