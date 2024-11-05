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