const Event = require('../models/EventModel');

exports.getEvents = async (req, res) => {
    try {
        const events = await Event.getAll();
        res.status(200).json(events);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving events' });
    }
};

exports.createEvent = async (req, res) => {
    const { name, type, startDate, endDate, maxParticipants } = req.body;
    try {
        console.log(Event);
        const newEvent = await Event.createEvent(name, type, startDate, endDate, maxParticipants);
        res.status(201).json(newEvent);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error creating event' });
    }
};

exports.getEventById = async (req, res) => {
    const { id } = req.params;
    try {
        const event = await Event.findById(id);
        if (event) {
            res.status(200).json(event);
        } else {
            res.status(404).json({ message: 'Event not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving event' });
    }
};

exports.updateEvent = async (req, res) => {
    const { id } = req.params;
    const { name, type, startDate, endDate, maxParticipants } = req.body;
    try {
        const updatedEvent = await Event.updateEvent(id, name, type, startDate, endDate, maxParticipants);
        if (updatedEvent) {
            res.status(200).json(updatedEvent);
        } else {
            res.status(404).json({ message: 'Event not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error updating event' });
    }
};

exports.deleteEvent = async (req, res) => {
    const { id } = req.params;
    try {
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