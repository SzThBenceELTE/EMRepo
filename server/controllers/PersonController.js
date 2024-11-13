const Person = require('../models/PersonModel');

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
    try {
        const deletedPerson = await Person.deletePerson(id);
        if (deletedPerson) {
            res.status(204).end();
        } else {
            res.status(404).json({ message: 'Person not found' });
        }
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error deleting person' });
    }
};