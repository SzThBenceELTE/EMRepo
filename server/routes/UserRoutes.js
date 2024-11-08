const express = require('express');
const router = express.Router();
const userController = require('../controllers/UserController');

router.post('/users/login', userController.loginUser);


// Define routes for users
router.get('/users', userController.getUsers);
router.post('/users', userController.createUser);
router.get('/users/:id', userController.getUserById);
router.get('/users/:name', userController.getUserByName);
router.get('/users/:email', userController.getUserByEmail);
router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

module.exports = router;