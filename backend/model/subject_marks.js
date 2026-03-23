const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const SubjectMark = sequelize.define(
  'SubjectMark',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    semester_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'semesters',
        key: 'id'
      },
      onDelete: 'CASCADE'
    },
    subject_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    ia1: {
      type: DataTypes.FLOAT,
      allowNull: true,
      defaultValue: 0
    },
    ia2: {
      type: DataTypes.FLOAT,
      allowNull: true,
      defaultValue: 0
    }
  },
  {
    tableName: 'subject_marks',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    underscored: true
  }
);

module.exports = SubjectMark;
