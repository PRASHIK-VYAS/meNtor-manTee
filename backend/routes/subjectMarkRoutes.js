const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const subjectMarkController = require('../controller/subjectMarkController');

router.use(authMiddleware);

router.get('/', subjectMarkController.getAll);
router.post('/', subjectMarkController.create);
router.get('/:id', subjectMarkController.getById);
router.put('/:id', subjectMarkController.update);
router.delete('/:id', subjectMarkController.remove);

module.exports = router;
