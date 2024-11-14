// sequelize.js

const path = require('path');
const { Sequelize } = require('sequelize');
const { Op } = require('sequelize'); // Import Sequelize operators

// Initialize Sequelize with SQLite
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: path.join(__dirname, 'database.sqlite'), // Adjust the path as needed
  logging: false, // Optional: Disable Sequelize logging
});

module.exports = sequelize;