const express = require('express');
const passport = require('passport');
const session = require('express-session');
const sqlite3 = require('better-sqlite3')

const cors = require('cors');
const path = require('path');

const userRoutes = require('./routes/UserRoutes'); // API routes for users
const personRoutes = require('./routes/PersonRoutes'); // API routes for people
const eventRoutes = require('./routes/EventRoutes'); // API routes for events
const homeRoutes = require('./routes/HomeRoutes'); // API routes for events

const db = require('./db');

const { init: initAuth } = require('./auth');


const app = express();
app.use(express.urlencoded({ extended: false }));
app.use(express.json());  // Middleware to parse JSON bodies

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
  // credentials: true, // Add this if you need to support cookies or HTTP authentication
};

app.use(cors(corsOptions));


// initAuth(); // Initialize authentication
// app.use(session({
//   secret: 'secret',
//   saveUninitialized: true,
//   resave: true
// }));
// app.use(passport.initialize());
// app.use(passport.session());


// API Routes
app.use('/api', userRoutes);
app.use('/api', personRoutes);
app.use('/api', eventRoutes);
app.use('/api', homeRoutes);

// Middleware to serve static Angular files
const angularPagePath = path.join(__dirname, '../event-manager-angular/dist/event-manager-angular');
app.use(express.static(angularPagePath));



// Fallback route to serve the Angular app for any other route
app.get('*', (req, res) => {
  res.sendFile(path.join(angularPagePath, 'index.html'));
});



const port = process.env.PORT || 3000;
db.sequelize.sync({ force: false }).then(() => {
  app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });
}).catch((err) => {
  console.error('Error syncing database:', err);
});