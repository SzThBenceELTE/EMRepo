// Define the join table between Event and Person
const { DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const Event = require('./EventModel');
const Person = require('./PersonModel');

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
  },{
    timestamps: false, // Disable timestamps if not needed
  });
  
  module.exports = EventParticipants;
  