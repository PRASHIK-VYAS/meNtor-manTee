const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const semesterController = require('../controller/semesterController');

router.use(authMiddleware);

router.get('/', semesterController.getAll);
router.get('/student/:studentId', semesterController.getByStudentId);
router.post('/', semesterController.create);
router.get('/:id', semesterController.getById);
router.put('/:id', semesterController.update);
router.patch('/:id', semesterController.update);
router.delete('/:id', semesterController.remove);
router.get('/:id/subject-marks', semesterController.getSubjectMarksForSemester);
router.post('/:id/subject-marks', semesterController.createSubjectMarkForSemester);

module.exports = router;
