const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const certificationController = require('../controller/certificationController');

router.use(authMiddleware);

router.get('/', certificationController.getAll);
router.get('/student/:studentId', certificationController.getByStudentId);
router.post('/', certificationController.create);
router.get('/:id', certificationController.getById);
router.put('/:id', certificationController.update);
router.patch('/:id', certificationController.update);
router.delete('/:id', certificationController.remove);

module.exports = router;
