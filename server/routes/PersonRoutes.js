const express = require('express');
const router = express.Router();
const personController = require('../controllers/PersonController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');

//Define routes for people - Person is the object representing a person who can be associated with events
//Gets every person in the system
router.get('/people', personController.getPersons);
//Gets every person in the system that is in the group
router.get('/people/group/:group', personController.getPersonsFromGroup);
//
//Gets all developers in the system
router.get('/people/developers', personController.getDevelopers);
//Gets all managers in the system
router.get('/people/managers', personController.getManagers);
//Fetch people with no teams
router.get('/people/noTeams', personController.getPersonsWithNoTeams);
//Creates a new Person
router.post('/people', personController.createPerson);
//Get user associated with the person
router.get('/people/:personId/user', personController.getUserFromPerson);
//Gets the person associated with this id
router.get('/people/:id', personController.getPersonById);
//Updates the person associated with this id
router.put('/people/:id', personController.updatePerson);
//Deletes the person associated with this id
router.delete('/people/:id', personController.deletePerson);
//Gets all events that the person is subscribed to for the phone app
router.get('/people/:personId/subscribed-events', personController.getSubscribedEvents);

//Fetch teams for a given person
router.get('/people/:personId/teams', personController.getTeamsForPerson);


module.exports = router;