// const path = require('path');
// const { Sequelize } = require('sequelize');

// module.exports = new Sequelize({
//   dialect: 'sqlite',
//   storage: path.join(__dirname, 'database.sqlite')
// });

const path = require('path');
const { Sequelize } = require('sequelize');

// Initialize Sequelize with SQLite
const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: path.join(__dirname, 'database.sqlite'), // Path to your SQLite file
    logging: false, // Optional: Disable Sequelize logging
});

// Sync all models (i.e., create tables if they don't exist)
sequelize.sync({ alter: true })
    .then(() => {
        console.log('Database synced and tables created (if not existing).');
    })
    .catch(err => {
        console.error('Error syncing database:', err);
    });

module.exports = sequelize;