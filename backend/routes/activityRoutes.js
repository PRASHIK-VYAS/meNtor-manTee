const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const activityController = require('../controller/activityController');

router.use(authMiddleware);

router.get('/', activityController.getAll);
router.get('/student/:id', activityController.getByStudentId);
router.post('/', activityController.create);
router.get('/:id', activityController.getById);
router.put('/:id', activityController.update);
router.delete('/:id', activityController.remove);

module.exports = router;
