// routes/healthRoute.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/authMiddleware');

// Public health check
// GET /api/health
router.get('/', (req, res) => {
  res.json({ status: 'OK', message: 'MUUD Health API is running' });
});

// Protected example route
// GET /api/health/protected
router.get('/protected', auth, (req, res) => {
  res.json({
    message: 'This is protected data from the server',
    userId: req.user.id,
  });
});

module.exports = router;