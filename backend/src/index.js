const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");
const healthRoute = require("./routes/healthRoute");
const authRoute = require("./routes/authRoute");

// load .env
dotenv.config();

//creates express app
const app = express();

// connect to MongoDB
connectDB();

// middlewares
app.use(cors()); //allows frontend to communicate with this backend.
app.use(express.json()); // to parse JSON body

// log every incoming request
app.use((req, res, next) => {
  console.log("➡️", req.method, req.url);
  next();
});

// routes
app.use("/health", healthRoute);
app.use('/api/health', require('./routes/healthRoute'));
app.use("/api/auth", authRoute);
app.use('/api/auth', require('./routes/authRoute'));

// default route
app.get("/", (req, res) => {
  res.send("MUUD_HEALTH backend is up 🚀");
});

// use PORT from env or 4000 by default
const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});