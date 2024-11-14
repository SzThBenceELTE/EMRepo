// db.js

const { Op } = require('sequelize'); // Import Sequelize operators
const sequelize = require('./sequelize'); // Import the sequelize instance
const bcrypt = require('bcryptjs');

// Import models
const Person = require('./models/PersonModel');
const User = require('./models/UserModel');
const Event = require('./models/EventModel');
const EventParticipants = require('./models/EventParticipants'); 

// Define associations after models are imported
Person.belongsTo(User, {
  onDelete: 'CASCADE',
  onUpdate: 'CASCADE',
}); // Each Person belongs to a User

User.hasOne(Person, {
  onDelete: 'CASCADE',
  onUpdate: 'CASCADE',
}); // Each User has one Person

Event.belongsToMany(Person, { through: EventParticipants, foreignKey: 'eventId' });
Person.belongsToMany(Event, { through: EventParticipants, foreignKey: 'personId' });

// Sync all models (i.e., create tables if they don't exist)
sequelize.sync({})
  .then(async () => {
    console.log('Database synced and tables created.');

    // Check if admin user exists
    const adminEmail = 'admin@example.com';
    const adminPassword = 'adminpassword'; // Use a secure password

    let adminUser;
    try {
      adminUser = await User.findOne({ where: { email: adminEmail } });
      console.log('adminUser:', adminUser);
    } catch (error) {
      console.error('Error fetching admin user:', error);
      return; // Exit if there's an error fetching admin user
    }

    if (!adminUser) {
      try {
        // Hash the password
        const hashedPassword = await bcrypt.hash(adminPassword, 10);

        // Create the user
        adminUser = await User.create({
          name: 'Admin',
          email: adminEmail,
          password: hashedPassword,
        });

        // Create the person and link to the user
        const adminPerson = await Person.create({
          firstName: 'Admin',
          surname: 'User',
          role: 'MANAGER', // Ensure this role exists in RoleEnum
          userId: adminUser.id,
        });
        await adminPerson.setUser(adminUser); // Associate the person with the user
        console.log('Admin user and person created.');
      } catch (error) {
        console.error('Error creating admin user and person:', error);
      }
    } else {
      console.log('Admin user already exists.');
    }

    // Delete events where endDate is in the past
    try {
      const now = new Date();
      const deletedCount = await Event.destroy({
        where: {
          endDate: {
            [Op.lt]: now
          }
        }
      });
      console.log(`${deletedCount} past event(s) deleted.`);
    } catch (error) {
      console.error('Error deleting past events:', error);
    }
    
  })
  .catch((err) => {
    console.error('Error syncing database:', err);
  });

// Export the models and sequelize instance if needed elsewhere
module.exports = {
  sequelize,
  Person,
  User,
  Event,
  EventParticipants,
};