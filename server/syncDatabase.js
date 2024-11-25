const sequelize = require('./sequelize');
const Event = require('./models/EventModel');
// Remove Group import
// const Group = require('./models/GroupModel');

const syncDatabase = async () => {
  try {
    await sequelize.sync({ alter: true }); // Adjust as needed
    console.log('Database synchronized successfully.');
  } catch (error) {
    console.error('Database synchronization failed:', error);
  }
};

syncDatabase();