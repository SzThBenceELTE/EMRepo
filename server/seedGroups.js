// server/seedGroups.js

const sequelize = require('./sequelize');
const Group = require('./models/GroupModel');
const GroupEnum = require('./enums/GroupEnum');

const seedGroups = async () => {
  try {
    await sequelize.sync({ force: false }); // Avoid dropping existing tables

    for (const groupName of GroupEnum) {
      await Group.findOrCreate({
        where: { name: groupName },
        defaults: { name: groupName },
      });
    }

    console.log('Groups seeded successfully.');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding groups:', error);
    process.exit(1);
  }
};

seedGroups();