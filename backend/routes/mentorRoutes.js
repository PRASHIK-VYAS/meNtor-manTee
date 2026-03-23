const express = require('express');
const router = express.Router(); // Create a router instance
const authMiddleware = require('../middleware/authMiddleware'); // Import the authentication middleware

const roleMiddleware = require('../middleware/roleMiddleware'); // Import the role-based access control middleware

const mentorController = require('../controller/mentorController'); // Import the mentor controller
router.use(authMiddleware);
router.use(roleMiddleware('mentor'));

router.get('/', mentorController.getAll);
router.post('/', mentorController.create);
router.get('/profile', mentorController.getMentorProfile);

const studentController = require('../controller/studentController');
router.get('/students/leaderboard', studentController.getLeaderboard);

router.get('/:id/students', mentorController.getMentorStudents);
router.get('/:id/activities', mentorController.getMentorActivities);
router.get('/:id/activities/pending', mentorController.getPendingActivities);
router.get('/:id/meetings', mentorController.getMentorMeetings);
router.get('/:id/broadcasts', mentorController.getMentorBroadcasts);
router.get('/:id/documents', mentorController.getMentorDocuments);
router.patch('/students/:studentId', mentorController.updateStudentProfile);
router.get('/:id', mentorController.getById);
router.put('/:id', mentorController.update);
router.patch('/activities/:activityId/approve', mentorController.approveActivity);
router.delete('/:id', mentorController.remove);



module.exports = router; // Export the router to be used in other parts of the application
