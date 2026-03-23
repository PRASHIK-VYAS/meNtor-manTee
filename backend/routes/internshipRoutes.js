const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const internshipController = require('../controller/internshipController');

router.use(authMiddleware);

router.get('/', internshipController.getAll);
router.get('/student/:studentId', internshipController.getByStudentId);
router.post('/', internshipController.create);
router.get('/:id', internshipController.getById);
router.put('/:id', internshipController.update);
router.patch('/:id', internshipController.update);
router.delete('/:id', internshipController.remove);

module.exports = router;
