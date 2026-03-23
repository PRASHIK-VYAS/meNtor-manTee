// backend\model\student.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Mentor = require('./mentor');

const Student = sequelize.define(
  'Student',
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
      allowNull: false
    },
    student_id: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    phone_number: {
      type: DataTypes.STRING,
      allowNull: true
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
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true
    },
    password: {
      type: DataTypes.STRING,
      allowNull: false
    },
    full_name: {
      type: DataTypes.STRING,
      allowNull: false
    },
    department: {
      type: DataTypes.STRING,
      allowNull: false
    },
    admission_type: {
      type: DataTypes.STRING,
      allowNull: false
    },
    date_of_birth: {
      type: DataTypes.DATEONLY,
      allowNull: false
    },
    date_of_joining: {
      type: DataTypes.DATEONLY,
      allowNull: true
    },
    role: {
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'student'
    },
    current_semester: {
      type: DataTypes.INTEGER,
      allowNull: true,
      defaultValue: 1
    },
    document_statuses: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: {}
    },
    document_file_paths: {
      type: DataTypes.JSON,
      allowNull: true,
      defaultValue: {}
    }
  },
  {
    tableName: 'students',
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  }
);

Student.belongsTo(Mentor, { foreignKey: 'mentor_id' });

module.exports = Student;
