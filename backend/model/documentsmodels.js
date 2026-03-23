const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const DocumentRequest = sequelize.define(
  'DocumentRequest',
  {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
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
      onDelete: 'CASCADE'
    },
    mentor_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: 'mentors',
        key: 'id'
      },
      onDelete: 'SET NULL'
    },
    title: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    description: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    type: {
      type: DataTypes.TEXT,
      allowNull: false
    },
    status: {
      type: DataTypes.TEXT,
      allowNull: true,
      defaultValue: 'Pending'
    },
    request_date: {
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: DataTypes.NOW
    },
    uploaded_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    file_path: {
      type: DataTypes.TEXT,
      allowNull: true
    },
    rejection_reason: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  },
  {
    tableName: 'document_requests',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    underscored: true
  }
);

module.exports = DocumentRequest;
