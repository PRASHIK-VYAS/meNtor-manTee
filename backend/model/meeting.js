const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Meeting = sequelize.define(
  'Meeting',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    student_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'students',
        key: 'id'
      },
      onDelete: 'SET NULL'
    },
    mentor_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'mentors',
        key: 'id'
      },
      onDelete: 'CASCADE'
    },
    batch_id: {
      type: DataTypes.STRING,
      allowNull: true
    },
    title: {
      type: DataTypes.STRING,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    meeting_date: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    meeting_time: {
      type: DataTypes.STRING,
      allowNull: false
    },
    link: {
      type: DataTypes.STRING,
      allowNull: true
    },
    location: {
      type: DataTypes.STRING,
      allowNull: true
    },
    type: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: 'One-on-One'
    },
    status: {
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: 'Scheduled'
    }
  },
  {
    tableName: 'meetings',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    underscored: true
  }
);

module.exports = Meeting;
