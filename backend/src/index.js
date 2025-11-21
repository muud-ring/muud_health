// index.js

const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

const authRoute = require('./routes/authRoute');
const healthRoute = require('./routes/healthRoute');

dotenv.config();
connectDB();

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
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
