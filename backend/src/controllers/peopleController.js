// backend/src/controllers/peopleController.js
const User = require("../models/User");

// GET /api/people?limit=20&page=1
exports.listPeople = async (req, res) => {
  try {
    const page = Math.max(parseInt(req.query.page || "1", 10), 1);
    const limit = Math.min(Math.max(parseInt(req.query.limit || "20", 10), 1), 50);
    const skip = (page - 1) * limit;

    // exclude me
    const query = { _id: { $ne: req.userId } };

    const [people, total] = await Promise.all([
      User.find(query)
        .select("fullName username bio location mood avatarUrl email phone") // keep safe fields
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit),
      User.countDocuments(query),
    ]);

    res.json({
      page,
      limit,
      total,
      people,
    });
  } catch (err) {
    console.error("listPeople error:", err);
    res.status(500).json({ message: "Failed to load people" });
  }
};

// GET /api/people/:id
exports.getPersonProfile = async (req, res) => {
  try {
    const { id } = req.params;

    const person = await User.findById(id).select(
      "fullName username bio location mood avatarUrl email phone"
    );

    if (!person) return res.status(404).json({ message: "User not found" });

    res.json({ person });
  } catch (err) {
    console.error("getPersonProfile error:", err);
    res.status(500).json({ message: "Failed to load profile" });
  }
};
