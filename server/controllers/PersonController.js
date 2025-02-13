const e = require('express');
const Person = require('../models/PersonModel');
const User = require('../models/UserModel');
const Team = require('../models/TeamModel');
const EventParticipants = require('../models/EventParticipants');
const sequelize = require('sequelize');

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

exports.getUserFromPerson = async (req, res) => {
    const { personId } = req.params;
    try {
        const person = await Person.findByPk(personId);
        if (!person) {
            return res.status(404).json({ message: 'Person not found' });
        }
        const user = await User.findByPk(person.UserId);
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }
        res.status(200).json(user);
    } catch (error) {
        console.error('Error fetching user from person:', error);
        res.status(500).json({ message: 'Internal server error.' });
    }
};

exports.createPerson = async (req, res) => {
    const { firstName, surname, role, group } = req.body;
    console.log(req.body);
    try {
        console.log("Controller");
        console.log(firstName, surname, role, group);
        const newPerson = await Person.createPerson(firstName, surname, role, group);

        const io = socketService.getIo();
        io.emit('refresh', { message: 'Person created', personId: newPerson.id });

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
            const io = socketService.getIo();
            io.emit('refresh', { message: 'Person updated', personId: updatedPerson.id });
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

        const io = socketService.getIo();
        io.emit('refresh', { message: 'Person deleted' });

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

exports.getTeamsForPerson = async (req, res) => {
    const { personId } = req.params;
    console.log('Fetching teams for personId:', personId);

    try {
        const person = await Person.findByPk(personId);
        if (!person) {
            return res.status(404).json({ message: 'Person not found.' });
        }

        const teams = await person.getTeams();
        console.log('Teams:', teams);

        res.status(200).json(teams);
    } catch (error) {
        console.error('Error fetching teams:', error);
        res.status(500).json({ message: 'Internal server error.' });
    }
};

exports.getPersonsWithNoTeams = async (req, res) => {
    try {
        const persons = await Person.findAll({
            include: [{
                model: Team,
                through: { attributes: [] }  // Exclude join table attributes if desired
            }]
        });

        // Now, each person should have a Teams property (an empty array if no teams)
        const personsWithNoTeams = persons.filter(person => person.Teams.length === 0);
        console.log('Persons with no teams:', personsWithNoTeams);

        res.status(200).json(personsWithNoTeams);
    } catch (error) {
        console.error('Error fetching persons with no teams:', error);
        res.status(500).json({ message: 'Internal server error.' });
    }
}