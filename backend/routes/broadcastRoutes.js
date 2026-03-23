const express = require('express');
const router = express.Router();
const authMiddleware = require('../middleware/authMiddleware');
const broadcastController = require('../controller/broadcastController');

router.use(authMiddleware);

router.get('/', broadcastController.getAll);
router.post('/', broadcastController.create);
router.get('/:id', broadcastController.getById);
router.put('/:id', broadcastController.update);
router.delete('/:id', broadcastController.remove);

module.exports = router;
