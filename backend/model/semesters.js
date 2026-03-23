const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Semester = sequelize.define(
  'Semester',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true
    },
    student_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: 'students',
        key: 'id'
      },
      onDelete: 'CASCADE'
    },
    semester_number: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    sgpa: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    cgpa: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    result_status: {
      type: DataTypes.STRING,
      allowNull: false
    },
    remarks: {
      type: DataTypes.TEXT,
      allowNull: true
    }
  },
  {
    tableName: 'semesters',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
    underscored: true,
    indexes: [
      {
        unique: true,
        fields: ['student_id', 'semester_number']
      }
    ]
  }
);

module.exports = Semester;
