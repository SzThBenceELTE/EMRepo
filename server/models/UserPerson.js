const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js


const UserPerson = sequelize.define('UserPerson', {
    userId: {
      type: Sequelize.INTEGER,
      references: {
        model: 'Users',
        key: 'id',
      },
    },
    personId: {
      type: Sequelize.INTEGER,
      references: {
        model: 'People',
        key: 'id',
      },
    },
  });
  
  // Create a user and a person, then link them in the join table
  async function linkUserToPerson(userId, personId) {
    sequelize.transaction(async (t) => {
    await UserPerson.create({
      userId,
      personId,
    }, { transaction: t });
  });
  }
  
  // Query the relationship
  async function getUserFromPerson(personId) {
    const userPerson = await UserPerson.findOne({ where: { personId } });
    const user = await User.findByPk(userPerson.userId);
    return user;
  }

module.exports = UserPerson;