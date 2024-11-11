// Define the join table between Event and Person
const EventParticipants = sequelize.define('EventParticipants', {
    eventId: {
      type: DataTypes.INTEGER,
      references: {
        model: Event,
        key: 'id',
      },
    },
    personId: {
      type: DataTypes.INTEGER,
      references: {
        model: Person,
        key: 'id',
      },
    },
    // You can also add extra fields to this table, such as role, status, etc.
  });
  
  module.exports = EventParticipants;
  