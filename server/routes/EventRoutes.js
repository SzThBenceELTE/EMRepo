const express = require('express');
const router = express.Router();
const eventController = require('../controllers/EventController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');
const multer = require('multer');

// Configure storage for multer
const storage = multer.diskStorage({
     destination: (req, file, cb) => {
       cb(null, 'uploads/events/');
     },
     filename: (req, file, cb) => {
       cb(null, Date.now() + '-' + file.originalname);
     },
   });
   
   // File filter to accept images only
   const fileFilter = (req, file, cb) => {
     if (file.mimetype.startsWith('image/')) {
       cb(null, true);
     } else {
       cb(new Error('Only image files are allowed!'), false);
     }
   };
   
   const upload = multer({ storage: storage, fileFilter: fileFilter });
   
//Is the Person subscribed to the given event? - Boolean style
router.get('/events/:eventId/isSubscribed/:personId',
     eventController.isPersonSubscribedToEvent);
//Gets all main events in the future, with subevents attached
router.get('/events', eventController.getEvents);

//Gets all events in the future, also subevents directly
router.get('/events/all', eventController.getAllEvents);
//Gets every event ever created
router.get('/events/allandpast', eventController.getAllAndPastEvents);
//Gets every main event ever created, with subevents attached
router.get('/events/allandpastmain', eventController.getAllAndPastMainEvents);
// router.get('/events/:date', eventController.getEventsForDate);

//Creates a new event
router.post('/events', upload.single('image') , eventController.createEvent);
//Gets the event associated with this id
router.get('/events/:id', eventController.getEventById);
//Updates the event associated with this id
router.put('/events/:id', upload.single('image') , eventController.updateEvent);
//Deletes the event associated with this id
router.delete('/events/:id', eventController.deleteEvent);

//Event subscription for phone app
//Current user joins the event
router.post('/events/join', eventController.joinEvent);
//Current user leaves the event
router.post('/events/leave', eventController.leaveEvent);
//Get all people subscribed to an event
router.get('/events/:eventId/subscribedUsers', eventController.getSubscribedUsers);
//Get all events, that are subscribed to by the given person
router.get('/events/:personId/subscribedEvents', eventController.getSubscribedEventsForPerson);



module.exports = router;