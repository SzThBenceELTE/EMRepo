const express = require('express');
const router = express.Router();
const eventController = require('../controllers/EventController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');


router.get('/events/:eventId/isSubscribed/:personId',
     eventController.isPersonSubscribedToEvent);
router.get('/events', eventController.getEvents);
router.post('/events', eventController.createEvent);
router.get('/events/:id', eventController.getEventById);
router.put('/events/:id', eventController.updateEvent);
router.delete('/events/:id', eventController.deleteEvent);
router.post('/events/join', eventController.joinEvent);
router.post('/events/leave', eventController.leaveEvent);


module.exports = router;