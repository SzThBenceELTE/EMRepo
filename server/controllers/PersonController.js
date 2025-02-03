const e = require('express');
const Person = require('../models/PersonModel');
const User = require('../models/UserModel');
const EventParticipants = require('../models/EventParticipants');

exports.getPersons = async (req, res) => {
    try {
        const persons = await Person.getAll();
        console.log(persons);
        res.status(200).json(persons);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving persons' });
    }
};

exports.getPersonsFromGroup = async (req, res) => {
    const { group } = req.params;
    try {
        let persons = await Person.getAll()
        persons = persons.filter(person => person.role === 'DEVELOPER' && person.group === group.toUpperCase());
        console.log(persons);
        res.status(200).json(persons);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving persons' });
    }
};

exports.getDevelopers = async (req, res) => {
    try {
        let persons = await Person.getAll();
        persons = persons.filter(person => person.role === 'DEVELOPER');
        console.log(persons);
        res.status(200).json(persons);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving persons' });
    }   
};

exports.getManagers = async (req, res) => {
    try {
        let persons = await Person.getAll();
        persons = persons.filter(person => person.role === 'MANAGER');
        console.log(persons);
        res.status(200).json(persons);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving persons' });
    }
};

exports.createPerson = async (req, res) => {
    const { firstName, surname, role, group } = req.body;
    console.log(req.body);
    try {
        console.log("Controller");
        console.log(firstName, surname, role, group);
        const newPerson = await Person.createPerson(firstName, surname, role, group);
        res.status(201).json(newPerson);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error creating person' });
    }
};

exports.getPersonById = async (req, res) => {
    const { id } = req.params;
    try {
        const person = await Person.findById(id);
        if (person) {
            res.status(200).json(person);
        } else {
            res.status(404).json({ message: 'Person not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error retrieving person' });
    }
};

exports.updatePerson = async (req, res) => {
    const { id } = req.params;
    
    const { firstName, surname, role, group } = req.body;
    console.log("Controller");
    console.log(firstName, surname, role, group);
    try {
        const updatedPerson = await Person.updatePerson(id, firstName, surname, role, group);
        if (updatedPerson) {
            res.status(200).json(updatedPerson);
        } else {
            res.status(404).json({ message: 'Person not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error updating person' });
    }
};

exports.deletePerson = async (req, res) => {
    const { id } = req.params;
    console.log(`Deleting person with ID: ${id}`);
    
    try {
        const personToDelete = await Person.findByPk(id);

        const userIdToDelete = personToDelete.UserId;
        console.log(`Deleting user with ID: ${userIdToDelete}`);
        const userToDelete = await User.findByPk(userIdToDelete);

        if (!personToDelete) {
            return res.status(404).json({ message: 'Person not found' });
        }

        if (!userToDelete) {
            console.log(`User with ID: ${userIdToDelete} not found.`);
        }
    
        // Delete the person (this will cascade delete the associated user)
        await personToDelete.destroy();
        await userToDelete.destroy();
        
    
        console.log(`Person with ID: ${id} and associated User deleted successfully.`);
        res.status(204).end();
    } catch (error) {
      console.error('Error deleting person:', error);
      res.status(500).json({ message: 'Error deleting person' });
    }
  };

exports.getSubscribedEvents = async (req, res) => {
    const { personId } = req.params;
    console.log('Fetching subscribed events for personId:', personId);

    try {
        const subscriptions = await EventParticipants.findAll({
            where: { personId: personId },
            attributes: ['eventId'],
        });

        const eventIds = subscriptions.map(sub => sub.eventId);
        console.log('Subscribed Event IDs:', eventIds);

        res.status(200).json({ subscribedEventIds: eventIds });
    } catch (error) {
        console.error('Error fetching subscribed events:', error);
        res.status(500).json({ message: 'Internal server error.' });
    }
};