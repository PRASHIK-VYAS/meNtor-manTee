const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const taskController = require('../controller/taskController');

router.use(authMiddleware);

router.get('/', taskController.getAll);
router.get('/student/:studentId', taskController.getByStudentId);
router.post('/bulk', taskController.createBulk);
router.post('/', taskController.create);
router.get('/:id', taskController.getById);
router.put('/:id', taskController.update);
router.patch('/:id', taskController.update);
router.delete('/:id', taskController.remove);

module.exports = router;
