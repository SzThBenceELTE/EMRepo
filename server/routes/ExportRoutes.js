const express = require('express');
const router = express.Router();
const exportController = require('../controllers/ExportController');
const { authenticateToken } = require('../controllers/auth/AuthenticationChecker');


router.get('/export/users', authenticateToken, exportController.exportUsers);
router.get('/export/people', authenticateToken, exportController.exportPeople);
router.get('/export/events', authenticateToken, exportController.exportEvents);
router.get('/export/teams', authenticateToken, exportController.exportTeams);

router.get('/export/all', authenticateToken, exportController.exportAll);

module.exports = router;