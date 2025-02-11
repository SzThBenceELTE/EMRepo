const {Op, Sequelize, DataTypes } = require('sequelize');
const sequelize = require('../sequelize'); // Import from sequelize.js
const EventEnum = require('../enums/EventEnum');
const now = new Date();

/*
  Need to add a team function, one app uses groups, the other teams, so they should'n interfere with eachother
    use groups as a template, but with dynamic elements here (teams are made and deleted)
*/

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
    imagePath: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    parentId: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'Events', // Name of the table
        key: 'id',
      },
    },
    groups: {
      type: DataTypes.TEXT, // Use TEXT to store JSON string
      defaultValue: '[]', // Empty JSON array as a string
      get() {
        const rawValue = this.getDataValue('groups');
        return JSON.parse(rawValue);
      },
      set(value) {
        this.setDataValue('groups', JSON.stringify(value));
      },
    },
    teams: {
      type: DataTypes.TEXT, // Use TEXT to store JSON string
      defaultValue: '[]', // Empty JSON array as a string
      get() {
        const rawValue = this.getDataValue('teams');
        return JSON.parse(rawValue);
      },
      set(value) {
        this.setDataValue('teams', JSON.stringify(value));
      },
    },
    location: {
      type: DataTypes.STRING,
    },
    description: {
      type: DataTypes.STRING,
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




// Event.getAll = async () => {
//   return await Event.findAll({
//     where: { parentId: null }, // Fetch only main events
//       include: [
//         {
//           model: Event,
//           as: 'subevents',
//           include: [
//             {
//               model: Event,
//               as: 'subevents', // Include nested subevents if needed
//             },
//           ],
//         },
//       ],
//     attributes: {
//       include: [
//         [
//           // Use a subquery to count participants
//           Sequelize.literal(`(
//             SELECT COUNT(*)
//             FROM EventParticipants AS ep
//             WHERE ep.EventId = Event.id
//           )`),
//           'currentParticipants',
//         ],
//       ],
//     },
//   });;
// };

Event.getAll = async () => {
  return await Event.findAll({
    where: { parentId: null,
      startDate: { [Op.gte]: now }, // Fetch only future events
     }, // Fetch only main events
    include: [
      {
        model: Event,
        as: 'subevents',
        attributes: {
          // Include all original attributes plus currentParticipants
          include: [
            [
              Sequelize.literal(`(
                SELECT COUNT(*)
                FROM "EventParticipants" AS ep
                WHERE ep."EventId" = "subevents"."id"
              )`),
              'currentParticipants',
            ],
          ],
        },
        // Include nested subevents if necessary
        include: [
          {
            model: Event,
            as: 'subevents',
            attributes: {
              include: [
                [
                  Sequelize.literal(`(
                    SELECT COUNT(*)
                    FROM "EventParticipants" AS ep
                    WHERE ep."EventId" = "subevents->subevents"."id"
                  )`),
                  'currentParticipants',
                ],
              ],
            },
          },
        ],
      },
    ],
    attributes: {
      include: [
        [
          Sequelize.literal(`(
            SELECT COUNT(*)
            FROM "EventParticipants" AS ep
            WHERE ep."EventId" = "Event"."id"
          )`),
          'currentParticipants',
        ],
      ],
    },
  });
};

Event.createEvent = async (name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams, location, description) => {
  try {
    const event = await Event.create({
      name,
      type,
      startDate,
      endDate,
      maxParticipants,
      imagePath: imagePath || null,
      parentId: parentId || null,
      groups: groups, // Assign groups directly
      teams: teams, // Assign teams directly
      location: location || '',
      description: description || '',
    });
    return event;
  } catch (error) {
    console.error('Create Event Error:', error);
    throw error;
  }
};

Event.createEventAlternative = async (name, type, startDate, endDate, maxParticipants, imagePath, parentId, teams, location, description) => {
  try {
    const event = await Event.create({
      name,
      type,
      startDate,
      endDate,
      maxParticipants,
      imagePath: imagePath || null,
      parentId: parentId || null,
      teams: teams, // Assign groups directly
      location: location || '',
      description: description || '',
    });
    return event;
  } catch (error) {
    console.error('Create Event Error:', error);
    throw error;
  }
};

Event.createEventFull = async (name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams) => {
  try {
    const event = await Event.create({
      name,
      type,
      startDate,
      endDate,
      maxParticipants,
      imagePath: imagePath || null,
      parentId: parentId || null,
      groups, // Assign groups directly
      teams, // Assign groups directly
    });
    return event;
  } catch (error) {
    console.error('Create Event Error:', error);
    throw error;
  }
};

// Fetch Event by ID Including Associated Groups
Event.findById = async (id) => {
  return await Event.findByPk(id);
};

Event.updateEvent = async (id, name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams, location, description) => {
  const event = await Event.findByPk(id);
  if (event) {
    event.name = name;
    event.type = type;
    event.startDate = startDate;
    event.endDate = endDate;
    event.maxParticipants = maxParticipants;
    event.imagePath = imagePath;
    event.parentId = parentId;
    event.groups = groups;
    event.teams = teams;
    event.location = location;
    event.description = description;
    return await event.save();
  }
  return null; // Event not found
};

Event.updateEventAlternative = async (id, name, type, startDate, endDate, maxParticipants, imagePath, parentId, teams) => {
  const event = await Event.findByPk(id);
  if (event) {
    event.name = name;
    event.type = type;
    event.startDate = startDate;
    event.endDate = endDate;
    event.maxParticipants = maxParticipants;
    event.imagePath = imagePath;
    event.parentId = parentId;
    event.groups = event.groups;  //keep it the same here
    event.teams = teams;
    return await event.save();
  }
  return null; // Event not found
};

Event.updateEventFull = async (id, name, type, startDate, endDate, maxParticipants, imagePath, parentId, teams) => {
  const event = await Event.findByPk(id);
  if (event) {
    event.name = name;
    event.type = type;
    event.startDate = startDate;
    event.endDate = endDate;
    event.maxParticipants = maxParticipants;
    event.imagePath = imagePath;
    event.parentId = parentId;
    event.groups = groups;
    event.teams = teams;
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