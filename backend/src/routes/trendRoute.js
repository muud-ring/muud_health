// routes/trendRoute.js
const express = require('express');
const router = express.Router();

const {
  getTrendsDashboard,
  updateTrendsDashboard,
} = require('../controllers/trendController');

// Use SAME middleware import style as healthRoute.js
const auth = require('../middleware/authMiddleware');

router.get('/dashboard', auth, getTrendsDashboard);
router.patch('/dashboard', auth, updateTrendsDashboard);

module.exports = router;
