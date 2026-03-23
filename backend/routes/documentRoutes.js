const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const documentController = require('../controller/documentController');

router.use(authMiddleware);

router.get('/', documentController.getAll);
router.post('/', documentController.create);
router.get('/:id', documentController.getById);
router.put('/:id', documentController.update);
router.patch('/:id', documentController.update);
router.delete('/:id', documentController.remove);

module.exports = router;
