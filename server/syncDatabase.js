const sequelize = require('./sequelize');
// Remove Group import
// const Group = require('./models/GroupModel');
const Person = require('./models/PersonModel');
const User = require('./models/UserModel');
const Event = require('./models/EventModel');
const Team = require('./models/TeamModel');
const EventParticipants = require('./models/EventParticipants');
const Group = require('./models/GroupModel');
const JoiningInfo = require('./models/JoiningInfoModel'); 

//Important: all the stuff needs to be included, or the sync doesn't see it

const syncDatabase = async () => {
  try {
    //await sequelize.getQueryInterface().dropTable('Events_backup', { force: true });
    //console.log('Table dropped successfully.');
    await sequelize.query('PRAGMA foreign_keys = OFF');
    await sequelize.sync({ alter: true }); // Adjust as needed
    await sequelize.query('PRAGMA foreign_keys = ON');
    console.log('Database synchronized successfully.');
  } catch (error) {
    console.error('Database synchronization failed:', error);
  }
};

syncDatabase();