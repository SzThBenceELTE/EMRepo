const express = require('express');
const router = express.Router();
const teamController = require('../controllers/TeamController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');



router.get('/teams', teamController.getTeams);
router.post('/teams', teamController.createTeam);
router.put('/teams/:id', teamController.editTeam);
router.delete('/teams/remove/:teamId/:personId', teamController.removePersonFromTeam);

router.delete('/teams/:id', teamController.deleteTeam);

router.get('/teams/:teamId/members', teamController.getMembers);
router.delete('/teams/:teamId/users', teamController.removeUsersFromTeam);


router.post('/teams/:teamId/users', teamController.addUsersToTeam);
router.post('/teams/add/:teamId/:personId', teamController.addPersonToTeam);

module.exports = router;

//router.get('/teams/:teamName/members', teamController.getMembers);
//router.get()