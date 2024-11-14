const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');

router.post('/users/login', userController.loginUser);
router.get('/users/me', authenticateToken, userController.getCurrentUser);


// Define routes for users
router.get('/users/:personId/subscribedEvents', 
    userController.getSubscribedEvents);
router.get('/users', userController.getUsers);
router.post('/users', userController.createUser);
router.get('/users/:id', userController.getUserById);
router.get('/users/:name', userController.getUserByName);
router.get('/users/:email', userController.getUserByEmail);
router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

module.exports = router;