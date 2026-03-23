const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const meetingController = require('../controller/meetingController');

router.use(authMiddleware);

router.get('/', meetingController.getAll);
router.get('/student/:studentId', meetingController.getByStudentId);
router.post('/', meetingController.create);
router.get('/:id', meetingController.getById);
router.put('/:id', meetingController.update);
router.delete('/:id', meetingController.remove);

module.exports = router;
