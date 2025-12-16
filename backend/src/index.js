// index.js

require("dotenv").config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const s3Route = require("./routes/s3Route");

const authRoute = require('./routes/authRoute');
const healthRoute = require('./routes/healthRoute');
const profileRoute = require('./routes/profileRoute');
const trendRoutes = require('./routes/trendRoute');
const journalRoutes = require('./routes/journalRoute');

console.log("➡️ Calling connectDB()");
connectDB();
console.log("✅ connectDB() called");


const app = express();

// Allow JSON bodies
app.use(express.json());

// CORS – allow your Flutter app to talk to this API
app.use(
  cors({
    origin: '*', // you can restrict this later
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  })
);

// Simple health check
app.get('/', (req, res) => {
  res.send('MUUD Health API is running');
});

// Public auth routes (NO auth middleware here)
app.use('/api/auth', authRoute);

// Protected health routes (these can use JWT middleware inside healthRoute)
app.use('/api/health', healthRoute);

app.use("/api/s3", s3Route);

app.use('/api/profile', profileRoute);
app.use('/api/trends', trendRoutes);

app.use('/api/journals', journalRoutes);

// Catch-all for unknown routes
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route not found' });
});

// Global error handler (just in case)
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ message: 'Server error.' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on ${PORT}`));