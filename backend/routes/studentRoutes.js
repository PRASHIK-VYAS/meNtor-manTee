const express = require('express');
const router = express.Router();

const studentController = require('../controller/studentController');
const authMiddleware = require('../middleware/authMiddleware');
const roleMiddleware = require('../middleware/roleMiddleware');

router.use(authMiddleware);

// Leaderboard and Profile accessible by both
router.get('/leaderboard', roleMiddleware(['student', 'mentor']), studentController.getLeaderboard);
router.get('/profile/:studentId', roleMiddleware(['student', 'mentor']), studentController.getStudentProfileById);
router.get('/:studentId', roleMiddleware(['student', 'mentor']), studentController.getStudentProfileById);

// More sensitive routes
router.get('/', roleMiddleware(['student', 'mentor']), studentController.getAll);
router.post('/', roleMiddleware(['student', 'mentor']), studentController.create);
router.put('/:id', roleMiddleware(['student', 'mentor']), studentController.update);
router.delete('/:id', roleMiddleware('mentor'), studentController.remove);

module.exports = router;
