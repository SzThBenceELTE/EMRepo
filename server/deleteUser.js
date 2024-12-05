const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('./sequelize'); // Adjust the path to your sequelize instance
const User = require('./models/UserModel'); // Adjust the path to your User model

async function deleteUser(userId) {
  try {
    const user = await User.findByPk(userId);
    if (!user) {
      console.log(`User with ID ${userId} not found.`);
      return;
    }

    await user.destroy();
    console.log(`User with ID ${userId} deleted successfully.`);
  } catch (error) {
    console.error('Error deleting user:', error);
  } finally {
    await sequelize.close();
  }
}

const userIdToDelete = 5;

deleteUser(userIdToDelete);