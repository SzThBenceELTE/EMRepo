const express = require('express');
const router = express.Router();
const userController = require('../controllers/PersonController');

router.get('/people', userController.getPeople);
router.post('/people', userController.createPerson);
router.get('/people/:id', userController.getPersonById);
router.put('/people/:id', userController.updatePerson);
router.delete('/people/:id', userController.deletePerson);