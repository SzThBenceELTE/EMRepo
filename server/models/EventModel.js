const { Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const EventEnum = require('../enums/EventEnum');

const Event = sequelize.define(
  'Event',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    name: {
      type: DataTypes.STRING,
    },
    type: {
      type: DataTypes.ENUM(EventEnum),
      allowNull: false,
    },
    startDate: {
      type: DataTypes.DATE,
    },
    endDate: {
      type: DataTypes.DATE,
    },
    maxParticipants: {
      type: DataTypes.INTEGER,
    },
  },
  {
    validate: {
      dateValidation() {
        if (this.startDate > this.endDate) {
          throw new Error('End date must be greater than start date.');
        }
      }
    }
  }
);



Event.getAll = async () => {
  return await Event.findAll();
};

Event.createEvent = async (name, type, startDate, endDate, maxParticipants) => {
  return await Event.create({ name, type, startDate, endDate, maxParticipants });
};

Event.findById = async (id) => {
  return await Event.findByPk(id);
};

Event.updateEvent = async (id, name, type, startDate, endDate, maxParticipants) => {
  const event = await Event.findByPk(id);
  if (event) {
    event.name = name;
    event.type = type;
    event.startDate = startDate;
    event.endDate = endDate;
    event.maxParticipants = maxParticipants;
    return await event.save();
  }
  return null; // Event not found
};

Event.deleteEvent = async (id) => {
  const event = await Event.findByPk(id);
  if (event) {
    return await event.destroy();
  }
  return null; // Event not found
};

module.exports = Event;