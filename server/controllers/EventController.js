const Event = require('../models/EventModel');
const EventParticipants = require('../models/EventParticipants');
const JoiningInfos = require('../models/JoiningInfoModel');
const People = require('../models/PersonModel');
const {Op,Sequelize} = require('sequelize');
const now = new Date();

// exports.getEvents = async (req, res) => {
//   try {
//     // const role = req.user.Person.role;
//     // const userGroup = req.user.Person.group;

//     console.log('req: ', req);

//     let events = await Event.getAll();

//     // if (role === 'DEVELOPER' && userGroup) {
//     //   // Filter events to include only those assigned to the developer's group
//     //   events = events.filter(event => {
//     //     const eventGroups = event.Groups.map(group => group.name);
//     //     const subeventGroups = event.subevents.flatMap(sub => sub.Groups.map(group => group.name));
//     //     const allGroups = [...eventGroups, ...subeventGroups];
//     //     return allGroups.includes(userGroup);
//     //   });
//     // }

//     res.status(200).json(events);
//   } catch (error) {
//     console.error('Get Events Error:', error);
//     res.status(500).json({ message: 'Error retrieving events' });
//   }
// };



exports.getAllEvents = async (req, res) => {
  try {
    const events = await Event.findAll({
      where: { 
        startDate: { [Op.gte]: now }, // Only events that haven't started yet
      }, // Fetch only main events
      attributes: {
        include: [
          [
            // Count participants for main events
            Sequelize.literal(`(
              SELECT COUNT(*)
              FROM EventParticipants AS ep
              WHERE ep.EventId = "Event"."id"
            )`),
            'currentParticipants',
          ],
        ],
      },
      include: [
        {
          model: Event,
          as: 'subevents',
          attributes: {
            include: [
              [
                // Count participants for first-level subevents
                Sequelize.literal(`(
                  SELECT COUNT(*)
                  FROM EventParticipants AS ep
                  WHERE ep.EventId = "subevents"."id"
                )`),
                'currentParticipants',
              ],
            ],
          },
          include: [
            {
              model: Event,
              as: 'subevents', // Nested subevents
              attributes: {
                include: [
                  [
                    // Count participants for second-level subevents
                    Sequelize.literal(`(
                      SELECT COUNT(*)
                      FROM EventParticipants AS ep
                      WHERE ep.EventId = "subevents->subevents"."id"
                    )`),
                    'currentParticipants',
                  ],
                ],
              },
            },
          ],
        },
      ],
    });

    res.status(200).json(events);
  } catch (error) {
    console.error('Get Events Error:', error);
    res.status(500).json({ message: 'Error retrieving events' });
  }
};

exports.getAllAndPastEvents = async (req, res) => {
  try {
    const events = await Event.findAll({
      attributes: {
        include: [
          [
            // Count participants for main events
            Sequelize.literal(`(
              SELECT COUNT(*)
              FROM EventParticipants AS ep
              WHERE ep.EventId = "Event"."id"
            )`),
            'currentParticipants',
          ],
        ],
      },
      include: [
        {
          model: Event,
          as: 'subevents',
          attributes: {
            include: [
              [
                // Count participants for first-level subevents
                Sequelize.literal(`(
                  SELECT COUNT(*)
                  FROM EventParticipants AS ep
                  WHERE ep.EventId = "subevents"."id"
                )`),
                'currentParticipants',
              ],
            ],
          },
          include: [
            {
              model: Event,
              as: 'subevents', // Nested subevents
              attributes: {
                include: [
                  [
                    // Count participants for second-level subevents
                    Sequelize.literal(`(
                      SELECT COUNT(*)
                      FROM EventParticipants AS ep
                      WHERE ep.EventId = "subevents->subevents"."id"
                    )`),
                    'currentParticipants',
                  ],
                ],
              },
            },
          ],
        },
      ],
    });

    res.status(200).json(events);
  } catch (error) {
    console.error('Get Events Error:', error);
    res.status(500).json({ message: 'Error retrieving events' });
  }
};

exports.getAllAndPastMainEvents = async (req, res) => {
  try {
    const events = await Event.findAll({
      where: {parentId: null},
      attributes: {
        include: [
          [
            // Count participants for main events
            Sequelize.literal(`(
              SELECT COUNT(*)
              FROM EventParticipants AS ep
              WHERE ep.EventId = "Event"."id"
            )`),
            'currentParticipants',
          ],
        ],
      },
      include: [
        {
          model: Event,
          as: 'subevents',
          attributes: {
            include: [
              [
                // Count participants for first-level subevents
                Sequelize.literal(`(
                  SELECT COUNT(*)
                  FROM EventParticipants AS ep
                  WHERE ep.EventId = "subevents"."id"
                )`),
                'currentParticipants',
              ],
            ],
          },
          include: [
            {
              model: Event,
              as: 'subevents', // Nested subevents
              attributes: {
                include: [
                  [
                    // Count participants for second-level subevents
                    Sequelize.literal(`(
                      SELECT COUNT(*)
                      FROM EventParticipants AS ep
                      WHERE ep.EventId = "subevents->subevents"."id"
                    )`),
                    'currentParticipants',
                  ],
                ],
              },
            },
          ],
        },
      ],
    });

    res.status(200).json(events);
  } catch (error) {
    console.error('Get Events Error:', error);
    res.status(500).json({ message: 'Error retrieving events' });
  }
};

exports.getEvents = async (req, res) => {
  try {
    const events = await Event.findAll({
      where: { 
        parentId: null,
        startDate: { [Op.gte]: now }, // Only events that haven't started yet
      }, // Fetch only main events
      attributes: {
        include: [
          [
            // Count participants for main events
            Sequelize.literal(`(
              SELECT COUNT(*)
              FROM EventParticipants AS ep
              WHERE ep.EventId = "Event"."id"
            )`),
            'currentParticipants',
          ],
        ],
      },
      include: [
        {
          model: Event,
          as: 'subevents',
          attributes: {
            include: [
              [
                // Count participants for first-level subevents
                Sequelize.literal(`(
                  SELECT COUNT(*)
                  FROM EventParticipants AS ep
                  WHERE ep.EventId = "subevents"."id"
                )`),
                'currentParticipants',
              ],
            ],
          },
          include: [
            {
              model: Event,
              as: 'subevents', // Nested subevents
              attributes: {
                include: [
                  [
                    // Count participants for second-level subevents
                    Sequelize.literal(`(
                      SELECT COUNT(*)
                      FROM EventParticipants AS ep
                      WHERE ep.EventId = "subevents->subevents"."id"
                    )`),
                    'currentParticipants',
                  ],
                ],
              },
            },
          ],
        },
      ],
    });

    res.status(200).json(events);
  } catch (error) {
    console.error('Get Events Error:', error);
    res.status(500).json({ message: 'Error retrieving events' });
  }
};

exports.createEvent = async (req, res) => {
  const { name, type, startDate, endDate, maxParticipants, parentId, location, description } = req.body;
  console.log("Request Body: " + JSON.stringify(req.body));
  console.log("Request File: " + JSON.stringify(req.file));


  let loc = location ? location : null;
  let desc = description ? description : null;
  
 

  let groups = req.body.groups;
  
  if (!Array.isArray(groups)) {
    if (groups) {
      groups = [groups];
    } else {
      groups = [];
    }
  }

  let teams = req.body.teams;
  console.log("Teams: " + teams);

  if (!Array.isArray(teams)) {
    if (teams) {
      teams = [teams];
    } else {
      teams = [];
    }
  }
  

  try {
    // If it's a subevent (parentId is provided), fetch the main event
    console.log("Parent ID: " + parentId);
    if (parentId && parentId != '' && parentId != null && parentId != undefined) {
      console.log("Went into subevent")
      const mainEvent = await Event.findByPk(parentId);
      console.log("Main Event: " + mainEvent);
      if (!mainEvent) {
        return res.status(404).json({ message: 'Main event not found.' });
      }

      // Validate maxParticipants
      if (maxParticipants > mainEvent.maxParticipants) {
        return res.status(400).json({
          message: 'Subevent cannot have more participants than the main event.',
        });
      }

      // Validate start date and end date
      const mainEventStartDate = new Date(mainEvent.startDate);
      const subEventStartDate = new Date(startDate);

      console.log("Main Event date: " + mainEventStartDate);
      console.log("Sub Event date: " + subEventStartDate);

      if (subEventStartDate < mainEventStartDate) {
        return res.status(400).json({
          message: 'Subevent cannot start before the main event ends.',
        });
      }

      const mainEventEndDate = new Date(mainEvent.endDate);

      const twoHoursAfterMainEvent = new Date(mainEventEndDate.getTime() + 2 * 60 * 60 * 1000); // Add 2 hours
      console.log("2 hour cutoff: " + twoHoursAfterMainEvent);

      if (subEventStartDate > twoHoursAfterMainEvent) {
        return res.status(400).json({
          message: 'Subevent must start no later than 2 hours after the main event ends.',
        });
      }

      // **New Validation: Subevent Groups**
      const mainEventGroups = mainEvent.groups; // Array of group names
      const subEventGroups = groups || []; // Subevent groups from request

      // Ensure all subEventGroups are in mainEventGroups
      const invalidGroups = subEventGroups.filter(group => !mainEventGroups.includes(group));
      console.log("Invalid Groups: " + invalidGroups);

      if (invalidGroups.length > 0) {
        return res.status(400).json({
          message: `Invalid group(s) for subevent: ${invalidGroups.join(', ')}. Subevent groups must be a subset of the main event's groups.`,
        });
      }

      

    }

    let imagePath = null;
    if (req.file) {
      imagePath = req.file.path;
    }

    //this needs fixing2
    console.log("Sending: " + name + " " + type + " " + startDate + " " + endDate + " " + maxParticipants + " " + imagePath + " " + parentId + " " + groups + " " + teams + " " + loc + " " + desc);
    const event = await Event.createEvent(name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams, loc, desc);

    // Proceed to create the event
    //const event = await Event.createEvent(name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams, loc, desc);

    res.status(201).json(event);
  } catch (error) {
    console.error('Create Event Error:', error);
    res.status(500).json({ message: 'Error creating event' });
  }
};

exports.getEventById = async (req, res) => {
  const { id } = req.params;
  try {
    const event = await Event.findByPk(id, {
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
                  WHERE ep."EventId" = "subevents"."id"
                )`),
                'currentParticipants',
              ],
            ],
          },
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

    if (event) {
      res.status(200).json(event);
    } else {
      res.status(404).json({ message: 'Event not found' });
    }
  } catch (error) {
    console.error('Get Event By ID Error:', error);
    res.status(500).json({ message: 'Error retrieving event' });
  }
};

exports.updateEvent = async (req, res) => {
  const { id } = req.params;
  const { name, type, startDate, endDate, maxParticipants, parentId, location, description} = req.body;
  
  console.log("Request Params: " + JSON.stringify(req.params));
  console.log("Request Body: " + JSON.stringify(req.body));
  console.log("Request File: " + JSON.stringify(req.file));
 
  let loc = location ? location : null;
  let desc = description ? description : null;

  let groups = req.body.groups;
  

  if (!Array.isArray(groups)) {
    if (groups) {
      groups = [groups];
    } else {
      groups = [];
    }
  }

  let teams = req.body.teams;
  console.log("Teams: " + teams);

  if (!Array.isArray(teams)) {
    if (teams) {
      teams = [teams];
    } else {
      teams = [];
    }
  }
  
  try {
    // If updating a subevent, perform validation
    console.log("Parent ID: " + parentId);
    if (parentId) {
      const mainEvent = await Event.findByPk(parentId);
      console.log("Main Event: " + mainEvent);
      if (!mainEvent) {
        return res.status(404).json({ message: 'Main event not found.' });
      }

      // Validate maxParticipants
      if (maxParticipants > mainEvent.maxParticipants) {
        return res.status(400).json({
          message: 'Subevent cannot have more participants than the main event.',
        });
      }

      // Validate start date and end date
      const mainEventEndDate = new Date(mainEvent.endDate);
      const subEventStartDate = new Date(startDate);

      if (subEventStartDate < mainEventEndDate) {
        return res.status(400).json({
          message: 'Subevent cannot start before the main event ends.',
        });
      }

      const twoHoursAfterMainEvent = new Date(
        mainEventEndDate.getTime() + 2 * 60 * 60 * 1000
      ); // Add 2 hours

      if (subEventStartDate > twoHoursAfterMainEvent) {
        return res.status(400).json({
          message: 'Subevent must start no later than 2 hours after the main event ends.',
        });
      }

      // **New Validation: Subevent Groups**
      const mainEventGroups = mainEvent.groups; // Array of group names
      const subEventGroups = groups || []; // Subevent groups from request

      // Ensure all subEventGroups are in mainEventGroups
      const invalidGroups = subEventGroups.filter(group => !mainEventGroups.includes(group));
      console.log("Invalid Groups: " + invalidGroups);

      if (invalidGroups.length > 0) {
        return res.status(400).json({
          message: `Invalid group(s) for subevent: ${invalidGroups.join(', ')}. Subevent groups must be a subset of the main event's groups.`,
        });
      }
    }

    let imagePath = null;
    if (req.file) {
      imagePath = req.file.path;
    }

    // Proceed to update the event
    const updatedEvent = await Event.updateEvent(id, name, type, startDate, endDate, maxParticipants, imagePath, parentId, groups, teams, loc, desc);
    if (updatedEvent) {
      res.status(200).json(updatedEvent);
    } else {
      res.status(404).json({ message: 'Event not found' });
    }
  } catch (error) {
    console.error('Update Event Error:', error);
    res.status(500).json({ message: 'Error updating event'});
  }
};

exports.deleteEvent = async (req, res) => {
    const { id } = req.params;
    try {
        
        const event = await Event.findByPk(id);
        const deletedEvent = await Event.deleteEvent(id);
        if (deletedEvent) {
            res.status(204).end();
        } else {
            res.status(404).json({ message: 'Event not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error deleting event' });
    }
};

exports.joinEvent = async (req, res) => {
    const { eventId, personId } = req.body;
  
    try {
      const event = await Event.findByPk(eventId);
      if (!event) {
        return res.status(404).json({ message: 'Event not found.' });
      }
  
      // Count current participants
      const participantCount = await event.countPeople();
  
      if (participantCount >= event.maxParticipants) {
        return res.status(400).json({ message: 'Event is full.' });
      }
  
      // Check if the person is already participating
      const isParticipant = await event.hasPerson(personId);
      if (isParticipant) {
        return res.status(400).json({ message: 'Person already joined.' });
      }
  
      // Add person to the event
      await event.addPerson(personId);
  
      res.status(200).json({ message: 'Successfully joined the event.' });
    } catch (error) {
      console.error('Join Event Error:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  exports.leaveEvent = async (req, res) => {
    const { eventId, personId } = req.body;
  
    try {
      const event = await Event.findByPk(eventId);
      if (!event) {
        return res.status(404).json({ message: 'Event not found.' });
      }
  
      // Check if the person is a participant
      const isParticipant = await event.hasPerson(personId);
      if (!isParticipant) {
        return res.status(400).json({ message: 'Person is not a participant.' });
      }
  
      // Remove person from the event
      await event.removePerson(personId);
  
      res.status(200).json({ message: 'Successfully left the event.' });
    } catch (error) {
      console.error('Leave Event Error:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  exports.isPersonSubscribedToEvent = async (req, res) => {
    const { eventId, personId } = req.body;
  
    try {
      const event = await Event.findByPk(eventId);
      if (!event) {
        return res.status(404).json({ message: 'Event not found.' });
      }
  
      // Check if the person is a participant
      const isParticipant = await event.hasPerson(personId);
  
      res.status(200).json({ subscribed: isParticipant });
    } catch (error) {
      console.error('Check Subscription Error:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  exports.getSubscribedUsers = async (req, res) => {
    // Get the eventId from the request (could be in req.body or as a URL parameter)
    const eventId = req.params.eventId; // Or req.params.eventId if using URL parameters
  
    try {
      // Find the event by primary key
      const event = await Event.findByPk(eventId);
      if (!event) {
        return res.status(404).json({ message: 'Event not found.' });
      }
  
      // Assuming the association is set up with a method like getPeople()
      // If your association uses a different alias, adjust accordingly.
      const subscribedUsers = await event.getPeople();
  
      // Optionally, you can format the users or filter fields before sending
      res.status(200).json({ 
        subscribedUsers: subscribedUsers 
      });
    } catch (error) {
      console.error('Error fetching subscribed users:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  exports.getEventsForDate = async (req, res) => {
    const date = req.params.date;
    try {
      const events = await Event.findAll({
        where: { 
          parentId: null,
          //startDate: { [Op.gte]: now }, // Only events that haven't started yet
          startDate: { [Op.eq]: req.params.date }, // Only events that happen today
        }, // Fetch only main events
        attributes: {
          include: [
            [
              // Count participants for main events
              Sequelize.literal(`(
                SELECT COUNT(*)
                FROM EventParticipants AS ep
                WHERE ep.EventId = "Event"."id"
              )`),
              'currentParticipants',
            ],
          ],
        },
        include: [
          {
            model: Event,
            as: 'subevents',
            attributes: {
              include: [
                [
                  // Count participants for first-level subevents
                  Sequelize.literal(`(
                    SELECT COUNT(*)
                    FROM EventParticipants AS ep
                    WHERE ep.EventId = "subevents"."id"
                  )`),
                  'currentParticipants',
                ],
              ],
            },
            include: [
              {
                model: Event,
                as: 'subevents', // Nested subevents
                attributes: {
                  include: [
                    [
                      // Count participants for second-level subevents
                      Sequelize.literal(`(
                        SELECT COUNT(*)
                        FROM EventParticipants AS ep
                        WHERE ep.EventId = "subevents->subevents"."id"
                      )`),
                      'currentParticipants',
                    ],
                  ],
                },
              },
            ],
          },
        ],
      });
  
      res.status(200).json(events);
    } catch (error) {
      console.error('Get Events Error:', error);
      res.status(500).json({ message: 'Error retrieving events' });
    }
  }

  exports.getSubscribedEventsForPerson = async (req, res) => {
    const { personId } = req.params;
    console.log('Fetching subscribed events for personId:', personId);
  
    try {
      // Fetch all event subscription records for the person
      const subscriptions = await EventParticipants.findAll({
        where: { personId: personId },
        attributes: ['eventId'],
      });
  
      // Map to an array of event IDs
      const eventIds = subscriptions.map(sub => sub.eventId);
      console.log('Subscribed Event IDs:', eventIds);
  
      // If there are no subscribed events, return an empty array
      if (eventIds.length === 0) {
        return res.status(200).json({ subscribedEvents: [] });
      }
  
      // Fetch the full event details corresponding to these IDs.
      // You can include associations (such as subevents, participant counts, etc.)
      const events = await Event.findAll({
        where: {
          id: {
            [Op.in]: eventIds,
          },
        },
        // Example: Include subevents and current participant counts if needed
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
                    WHERE ep."EventId" = "subevents"."id"
                  )`),
                  'currentParticipants',
                ],
              ],
            },
            include: [
              {
                model: Event,
                as: 'subevents', // Nested subevents
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
      });
  
      res.status(200).json({ subscribedEvents: events });
    } catch (error) {
      console.error('Error fetching subscribed events:', error);
      res.status(500).json({ message: 'Internal server error.' });
    }
  };

  // exports.getUploadImage = (req, res) => {
  //   // Extract the filename from the URL parameter
  //   const filename = req.params.filename;
    
  //   // Build the absolute path to the file.
  //   // Assuming your files are stored in "uploads/events/" relative to your project root.
  //   const imagePath = path.resolve(__dirname, '..', 'uploads', 'events', filename);
  
  //   // Send the file. sendFile will automatically set the correct Content-Type.
  //   res.sendFile(imagePath, (err) => {
  //     if (err) {
  //       console.error('Error sending file:', err);
  //       // If the file is not found, send a 404 error
  //       res.status(err.status || 404).json({ message: 'File not found' });
  //     }
  //   });
  // };