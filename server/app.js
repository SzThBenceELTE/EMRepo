if (process.env.NODE_ENV === 'test') {
    require('dotenv').config({ path: '.env.test' });
  } else {
    require('dotenv').config();
  }

const db = require('./db');
const express = require('express');
const path = require('path');
const morgan = require('morgan');
const cors = require('cors');

const userRoutes = require('./routes/UserRoutes'); // API routes for users
const personRoutes = require('./routes/PersonRoutes'); // API routes for people
const eventRoutes = require('./routes/EventRoutes'); // API routes for events
const homeRoutes = require('./routes/HomeRoutes');   // API routes for home
const teamRoutes = require('./routes/TeamRoutes');     // API routes for teams
const exportRoutes = require('./routes/ExportRoutes'); // API routes for exporting data

// Create the Express app
const app = express();

// Middleware to parse incoming data
app.use(express.urlencoded({ extended: false }));
app.use(express.json());

// Logging Middleware
app.use(morgan('combined'));

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, curl, etc.)
    if (!origin) return callback(null, true);
    // Allow any request from localhost (any port)
    if (origin.startsWith('http://localhost')) return callback(null, true);
    // Otherwise, disallow the request
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
};

app.use(cors(corsOptions));

// Serve static files from the 'uploads' directory
console.log('Serving uploads from:', path.join(__dirname, 'uploads'));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// API Routes
app.use('/api', userRoutes);
app.use('/api', personRoutes);
app.use('/api', eventRoutes);
app.use('/api', homeRoutes);
app.use('/api', teamRoutes);
app.use('/api', exportRoutes);

// Middleware to serve static Angular files
const angularPagePath = path.join(__dirname, '../event-manager-angular/dist/event-manager-angular');
app.use(express.static(angularPagePath));

// Fallback route to serve the Angular app for any other route
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/socket.io')) {
    // Let Socket.IO handle these requests
    return next();
  }
  res.sendFile(path.join(angularPagePath, 'index.html'));
});

module.exports = app;
