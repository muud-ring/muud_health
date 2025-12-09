// controllers/journalController.js

const Journal = require('../models/Journal');

// POST /api/journals
// Create a new journal for the logged-in user
exports.createJournal = async (req, res) => {
  try {
    const userId = req.user && req.user.id;

    if (!userId) {
      return res.status(401).json({ message: 'Not authorized' });
    }

    const { imageUrl, caption, visibility, emoji } = req.body;

    // Basic validation – we can tighten this later
    if (!caption && !imageUrl) {
      return res
        .status(400)
        .json({ message: 'Please provide at least imageUrl or caption.' });
    }

    const journal = await Journal.create({
      user: userId,
      imageUrl: imageUrl || '',
      caption: caption || '',
      visibility: visibility || 'Public',
      emoji: emoji || '',
    });

    return res.status(201).json(journal);
  } catch (err) {
    console.error('Error creating journal:', err);
    return res.status(500).json({ message: 'Failed to create journal.' });
  }
};

// GET /api/journals/me
// Get all journals for the logged-in user
exports.getMyJournals = async (req, res) => {
  try {
    const userId = req.user && req.user.id;

    if (!userId) {
      return res.status(401).json({ message: 'Not authorized' });
    }

    const journals = await Journal.find({ user: userId })
      .sort({ createdAt: -1 })
      .lean();

    return res.json(journals);
  } catch (err) {
    console.error('Error fetching journals:', err);
    return res.status(500).json({ message: 'Failed to fetch journals.' });
  }
};
