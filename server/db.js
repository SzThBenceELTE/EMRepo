// db.js

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
User.hasOne(Person);    // Each User has one Person


Event.belongsToMany(Person, { through: 'EventParticipants', foreignKey: 'eventId' });
Person.belongsToMany(Event, { through: 'EventParticipants', foreignKey: 'personId' });



// // Sync all models (i.e., create tables if they don't exist)
sequelize.sync({})
  .then(async () => {
    console.log('Database synced and tables created.');

    // Check if admin user exists
    const adminEmail = 'admin@example.com';
    const adminPassword = 'adminpassword'; // Use a secure password

    let adminUser = await User.findOne({ where: { email: adminEmail } });
    console.log('adminUser:', adminUser);

    if (!adminUser) {
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
      adminPerson.setUser(adminUser); // Associate the person with the user
      console.log('Admin user and person created.');
      } else {
      console.log('Admin user already exists.');
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