// sequelize.js

const path = require('path');
const { Sequelize } = require('sequelize');

// Initialize Sequelize with SQLite
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: path.join(__dirname, 'database.sqlite'), // Adjust the path as needed
  logging: false, // Optional: Disable Sequelize logging
});

module.exports = sequelize;