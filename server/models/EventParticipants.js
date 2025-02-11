// Define the join table between Event and Person
const { DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const Event = require('./EventModel');
const Person = require('./PersonModel');
const StatusEnum = require('../enums/StatusEnum');

const EventParticipants = sequelize.define('EventParticipants', {
    eventId: {
      type: DataTypes.INTEGER,
      primaryKey: true,  
      references: {
        model: Event,
        key: 'id',
      },
    },
    personId: {
      type: DataTypes.INTEGER,
      primaryKey: true, 
      references: {
        model: Person,
        key: 'id',
      },
    },
    status: {
      type: DataTypes.ENUM(StatusEnum),
      allowNull: true, // Change to true if the status can be omitted
    },
    application_time: {
      type: DataTypes.DATE,
      allowNull: true, // This can be null until an application is made
      defaultValue: DataTypes.NOW,
    }
  },{
    timestamps: false, // Disable timestamps if not needed
  });
  
  module.exports = EventParticipants;
  