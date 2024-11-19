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
    parentId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'Events', // Name of the table
        key: 'id',
      },
    },
  },
  {
    //tableName: 'Events', // Explicitly define the table name
    timestamps: true,
    validate: {
      dateValidation() {
        if (this.startDate > this.endDate) {
          throw new Error('End date must be greater than start date.');
        }
      },
      // **Prevent self-referencing**
      notSelfReferencing() {
        if (this.parentId && this.parentId === this.id) {
          throw new Error('An event cannot be a parent of itself.');
        }
      },
    }
  },
);




Event.getAll = async () => {
  return await Event.findAll({
    where: { parentId: null }, // Fetch only main events
      include: [
        {
          model: Event,
          as: 'subevents',
          include: [
            {
              model: Event,
              as: 'subevents', // Include nested subevents if needed
            },
          ],
        },
      ],
    attributes: {
      include: [
        [
          // Use a subquery to count participants
          Sequelize.literal(`(
            SELECT COUNT(*)
            FROM EventParticipants AS ep
            WHERE ep.EventId = Event.id
          )`),
          'currentParticipants',
        ],
      ],
    },
  });;
};

Event.createEvent = async (name, type, startDate, endDate, maxParticipants, parentId) => {
  console.log("Model");
  console.log(name, type, startDate, endDate, maxParticipants, parentId);
  return await Event.create({ 
    name, 
    type, 
    startDate, 
    endDate, 
    maxParticipants, 
    parentId: parentId || null, });
};

Event.findById = async (id) => {
  return await Event.findByPk(id);
};

Event.updateEvent = async (id, name, type, startDate, endDate, maxParticipants, parentId) => {
  const event = await Event.findByPk(id);
  if (event) {
    event.name = name;
    event.type = type;
    event.startDate = startDate;
    event.endDate = endDate;
    event.maxParticipants = maxParticipants;
    event.parentId = parentId;
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