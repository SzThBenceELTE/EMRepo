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
   

router.get('/events/:eventId/isSubscribed/:personId',
     eventController.isPersonSubscribedToEvent);
router.get('/events', eventController.getEvents);
router.post('/events', upload.single('image') , eventController.createEvent);
router.get('/events/:id', eventController.getEventById);
router.put('/events/:id', upload.single('image') , eventController.updateEvent);
router.delete('/events/:id', eventController.deleteEvent);
router.post('/events/join', eventController.joinEvent);
router.post('/events/leave', eventController.leaveEvent);



module.exports = router;