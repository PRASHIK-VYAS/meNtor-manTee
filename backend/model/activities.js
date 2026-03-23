const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database'); // Import the configured Sequelize instance
const Student = require('./student');

const Activity = sequelize.define('Activity', {

  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
    allowNull: false
  },

  student_id: {
    type: DataTypes.INTEGER,              // uuid
    allowNull: true
  },

  event_name: {
    type: DataTypes.TEXT,              // text
    allowNull: false
  },

  level: {
    type: DataTypes.TEXT,              // text
    allowNull: false
  },

  role: {
    type: DataTypes.TEXT,              // text
    allowNull: false
  },

  date: {
    type: DataTypes.DATEONLY,          // date
    allowNull: false
  },

  proof_url: {
    type: DataTypes.TEXT,              // text
    allowNull: true
  },

  is_verified: {
    type: DataTypes.BOOLEAN,           // boolean
    allowNull: true,
    defaultValue: false
  }

}, {
  tableName: 'activities',
  timestamps: true,
  createdAt: 'created_at',
  updatedAt: 'updated_at'
});


// Foreign key association
Activity.belongsTo(Student, {
  foreignKey: 'student_id',
  onDelete: 'CASCADE'  // If a student is deleted, their activities will also be deleted
});

module.exports = Activity;
