const { Notification } = require('../model');

exports.getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const limit = parseInt(req.query.limit) || 20;

    const notifications = await Notification.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
      limit
    });

    res.json(notifications);
  } catch (err) {
    console.error('Fetch Notifications Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await Notification.count({
      where: { userId, isRead: false }
    });
    res.json({ unreadCount: count });
  } catch (err) {
    console.error('Fetch Unread Count Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.markAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const notification = await Notification.findOne({
      where: { id, userId }
    });

    if (!notification) {
      return res.status(404).json({ error: 'Notification not found' });
    }

    notification.isRead = true;
    await notification.save();

    res.json({ message: 'Marked as read' });
  } catch (err) {
    console.error('Mark Read Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;
    await Notification.update(
      { isRead: true },
      { where: { userId, isRead: false } }
    );
    res.json({ message: 'All notifications marked as read' });
  } catch (err) {
    console.error('Mark All Read Error:', err);
    res.status(500).json({ error: err.message });
  }
};

exports.createNotification = async (req, res) => {
  try {
    const { userId, title, message, type } = req.body;
    
    // Validate
    if (!userId || !title || !message) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const notification = await Notification.create({
      userId,
      title,
      message,
      type: type || 'GENERAL'
    });

    res.status(201).json(notification);
  } catch (err) {
    console.error('Create Notification Error:', err);
    res.status(500).json({ error: err.message });
  }
};
