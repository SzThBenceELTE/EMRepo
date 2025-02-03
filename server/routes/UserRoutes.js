const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');

//Base login function with post - so post body exists, we can keep it hidden, add jwtSign
router.post('/users/login', userController.loginUser);
//Get the current user using the auth key
router.get('/users/me', authenticateToken, userController.getCurrentUser);


// Define routes for users - User is used for authentication
//Persons' subscribed events
router.get('/users/:personId/subscribedEvents', 
    userController.getSubscribedEvents);
//gets all users in the system
router.get('/users', userController.getUsers);
//creates a new user - This also creates the Person associated with the new user
router.post('/users', userController.createUser);
//gets the user associated with this id
router.get('/users/:id', userController.getUserById);
//gets the user associated with this name
router.get('/users/:name', userController.getUserByName);
//gets the user associated with this email
router.get('/users/:email', userController.getUserByEmail);
//updates the user associated with this id
router.put('/users/:id', userController.updateUser);
//deletes the user associated with this id - It won't delete the person, so old events won't be affected
router.delete('/users/:id', userController.deleteUser);

// New Route to Fetch Person by User ID
router.get('/users/:userId/person', userController.getPersonByUser);

module.exports = router;