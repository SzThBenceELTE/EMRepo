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
app.use(cors({
  origin: 'http://localhost:4200', // Adjust based on where your Angular app runs
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

initAuth(); // Initialize authentication
app.use(session({
  secret: 'secret',
  saveUninitialized: true,
  resave: true
}));
app.use(passport.initialize());
app.use(passport.session());

// Middleware to serve static Angular files
console.log(path.join(__dirname, '../event-manager-angular/views'));
app.use(express.static(path.join(__dirname, '../event-manager-angular/views')));

// API Routes
app.use('/api', userRoutes);
app.use('/api', personRoutes);
app.use('/api', eventRoutes);
app.use('/api', homeRoutes);


// Fallback route to serve the Angular app for any other route
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, '../event-manager-angular/src/index.html'));
});



const port = process.env.PORT || 3000;
db.sync({force:false}).then(() => {
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
})});