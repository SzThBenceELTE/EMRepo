const express = require('express');
const router = express.Router();
const eventController = require('../controllers/EventController');

router.get('/events', eventController.getEvents);
router.post('/events', eventController.createEvent);
router.get('/events/:id', eventController.getEventById);
router.put('/events/:id', eventController.updateEvent);
router.delete('/events/:id', eventController.deleteEvent);
router.post('/join', eventController.joinEvent);
router.post('/leave', eventController.leaveEvent);


module.exports = router;