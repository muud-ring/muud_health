// backend/src/middleware/authMiddleware.js
const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Not authorized, no token.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Your tokens are created as: jwt.sign({ userId }, ...)
    // But some routes are still using req.user.id.
    // So we support BOTH styles here.
    const userId = decoded.userId || decoded.id;

    if (!userId) {
      return res
        .status(401)
        .json({ message: 'Not authorized, invalid token payload.' });
    }

    // New style (what we’ve been using in profileController, etc.)
    req.userId = userId;

    // Backwards-compat style for older routes (healthRoute, journals, etc.)
    // so they can do req.user.id safely.
    req.user = { id: userId };

    next();
  } catch (err) {
    console.error('Auth middleware error:', err);
    return res.status(401).json({ message: 'Not authorized, token failed.' });
  }
};
