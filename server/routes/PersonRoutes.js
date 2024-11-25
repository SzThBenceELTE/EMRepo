const express = require('express');
const router = express.Router();
const personController = require('../controllers/PersonController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');


router.get('/people', personController.getPersons);
router.post('/people', personController.createPerson);
router.get('/people/:id', personController.getPersonById);
router.put('/people/:id', personController.updatePerson);
router.delete('/people/:id', personController.deletePerson);
router.get('/people/:personId/subscribed-events', personController.getSubscribedEvents);
module.exports = router;