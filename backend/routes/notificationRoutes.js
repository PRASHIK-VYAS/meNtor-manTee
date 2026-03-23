const express = require('express');
const router = express.Router();
const notificationController = require('../controller/notificationController');
const authMiddleware = require('../middleware/authMiddleware');

router.get('/', authMiddleware, notificationController.getNotifications);
router.get('/unread', authMiddleware, notificationController.getUnreadCount);
router.patch('/:id/read', authMiddleware, notificationController.markAsRead);
router.post('/mark-all-read', authMiddleware, notificationController.markAllAsRead);

// Allow internal system to create notification. In production, protect this route.
router.post('/', notificationController.createNotification);

module.exports = router;
