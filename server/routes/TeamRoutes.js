const express = require('express');
const router = express.Router();
const teamController = require('../controllers/TeamController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');

router.get('/teams', teamController.getTeams);
router.post('/teams', teamController.createTeam);
router.put('/teams/:id', teamController.editTeam);
router.delete('/teams/:id', teamController.deleteTeam);

module.exports = router;

//router.get('/teams/:teamName/members', teamController.getMembers);
//router.get()