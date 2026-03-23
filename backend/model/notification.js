// backend\model\notification.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Notification = sequelize.define('notification', {
  id: {
    // You can keep the notification's own ID as a UUID, that's perfectly fine!
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  userId: {
    // CHANGED: This is now an INTEGER to perfectly match Student.id and Mentor.id
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false,
  },
  type: {
    type: DataTypes.STRING, // e.g., 'DOCUMENT', 'TASK', 'BROADCAST'
    allowNull: false,
    defaultValue: 'GENERAL'
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
}, {
  timestamps: true,
  tableName: 'notifications',
});

module.exports = Notification;