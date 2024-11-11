// db.js

const sequelize = require('./sequelize'); // Import the sequelize instance

// Import models
const Person = require('./models/PersonModel');
const User = require('./models/UserModel');
const Event = require('./models/EventModel');


// Define associations after models are imported
Person.belongsTo(User); // Each Person belongs to a User
User.hasOne(Person);    // Each User has one Person

Event.belongsToMany(Person, { through: 'EventParticipants', foreignKey: 'eventId' });
Person.belongsToMany(Event, { through: 'EventParticipants', foreignKey: 'personId' });

// // Sync all models (i.e., create tables if they don't exist)
// sequelize
//   .sync({ alter: true })
//   .then(() => {
//     console.log('Database synced and tables created (if not existing).');
//   })
//   .catch((err) => {
//     console.error('Error syncing database:', err);
//   });
sequelize.sync({ alter: true })
  .then(async () => {
    console.log('Database synced and tables created.');

    // Check if admin user exists
    const adminEmail = 'admin@example.com';
    const adminPassword = 'adminpassword'; // Use a secure password

    let adminUser = await User.findOne({ where: { email: adminEmail } });

    if (!adminUser) {
      // Hash the password
      //const hashedPassword = await bcrypt.hash(adminPassword, 10);

      // Create admin user
      adminUser = await User.create({
        name: 'Admin',
        email: adminEmail,
        password: adminPassword,
      });
      console.log('Admin user created.');
    } else {
      console.log('Admin user already exists.');
    }

    // Check if admin person exists
    let adminPerson = await Person.findOne({ where: { userId: adminUser.id } });

    if (!adminPerson) {
      // Create admin person
      adminPerson = await Person.create({
        firstName: 'Admin',
        surname: 'User',
        role: 'MANAGER', // Use a valid role from RoleEnum
        userId: adminUser.id,
      });
      console.log('Admin person created.');
    } else {
      console.log('Admin person already exists.');
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
};