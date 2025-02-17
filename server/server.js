require('dotenv').config(); // Load environment variables at the very top

const express = require('express');
const passport = require('passport');
const session = require('express-session');
const sqlite3 = require('better-sqlite3')
// const {WebSocketServer} = require('ws');
const cors = require('cors');
const path = require('path');
const morgan = require('morgan'); // For logging
const http = require('http');
const socketIo = require('socket.io');

const userRoutes = require('./routes/UserRoutes'); // API routes for users
const personRoutes = require('./routes/PersonRoutes'); // API routes for people
const eventRoutes = require('./routes/EventRoutes'); // API routes for events
const homeRoutes = require('./routes/HomeRoutes'); // API routes for events
const teamRoutes = require('./routes/TeamRoutes'); // API routes for teams

const db = require('./db');

const { init: initAuth } = require('./auth');
const socketService = require('./socketService');

// Create the Express app
const app = express();
app.use(express.urlencoded({ extended: false }));
app.use(express.json());  // Middleware to parse JSON bodies




// Logging Middleware
app.use(morgan('combined')); // Logs detailed information about each request



// Modify the CORS options
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or servers)
    if (!origin) return callback(null, true);

    // Allow any request from localhost, regardless of port
    if (origin.startsWith('http://localhost')) {
      return callback(null, true);
    }

    // Disallow other origins
    return callback(new Error('Not allowed by CORS'));
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true, // Add this if you need to support cookies or HTTP authentication
};

app.use(cors(corsOptions));



const server = http.createServer(app);
const io = socketIo(server, {
  path: '/io', // Serve the Socket.IO server at /io
  cors: {
    origin: "http://localhost:4200", // Allow requests from your Angular app's origin
    methods: ["GET", "POST"],
    credentials: true, // if you need to support cookies or authentication
  }
});

socketService.init(io); // Initialize the socket service

// When a client connects
io.on('connection', (socket) => {
  console.log(`Client connected: ${socket.id}`);
  
  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});



// API Routes
//console.log('Serving events from:', path.join(__dirname, 'uploads', 'events'));
console.log('Serving uploads from:', path.join(__dirname, 'uploads'));
//app.use('/uploads/events', express.static(path.join(__dirname, 'uploads', 'events')));
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Serve static files from the 'uploads' directory
app.use('/api', userRoutes);
app.use('/api', personRoutes);
app.use('/api', eventRoutes);
app.use('/api', homeRoutes);
app.use('/api', teamRoutes);


// Middleware to serve static Angular files
const angularPagePath = path.join(__dirname, '../event-manager-angular/dist/event-manager-angular');
app.use(express.static(angularPagePath));



// Fallback route to serve the Angular app for any other route
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/socket.io')) {
    // Let Socket.IO handle it
    return next();
  }
  res.sendFile(path.join(angularPagePath, 'index.html'));
});


const port = process.env.PORT || 3000;
server.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

module.exports = app; // Export the app for testing