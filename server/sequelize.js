// sequelize.js

const path = require('path');
const { Sequelize } = require('sequelize');

// Choose a different storage file for testing
const storageFile = process.env.NODE_ENV === 'test'
  ? path.join(__dirname, 'database.test.sqlite') // Test database
  : path.join(__dirname, 'database.sqlite');      // Production/development database

// Initialize Sequelize with SQLite
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: storageFile,
  logging: false, // Disable detailed logging for clarity
});

module.exports = sequelize;