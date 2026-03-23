const { sequelize } = require('../config/database');
const Mentor = require('./mentor');
const Student = require('./student');
const Activity = require('./activities');
const Broadcast = require('./broadcastmodels');
const Certification = require('./certificationsmodels');
const DocumentRequest = require('./documentsmodels');
const Internship = require('./internshipmodels');
const Meeting = require('./meeting');
const Semester = require('./semesters');
const SubjectMark = require('./subject_marks');
const Task = require('./tasks');
const Notification = require('./notification');

Student.hasMany(Semester, { foreignKey: 'student_id', onDelete: 'CASCADE' });
Semester.belongsTo(Student, { foreignKey: 'student_id' });

Semester.hasMany(SubjectMark, { foreignKey: 'semester_id', onDelete: 'CASCADE' });
SubjectMark.belongsTo(Semester, { foreignKey: 'semester_id' });

Student.hasMany(Meeting, { foreignKey: 'student_id' });
Meeting.belongsTo(Student, { foreignKey: 'student_id' });

Mentor.hasMany(Meeting, { foreignKey: 'mentor_id', onDelete: 'CASCADE' });
Meeting.belongsTo(Mentor, { foreignKey: 'mentor_id' });

Student.hasMany(Task, { foreignKey: 'student_id', onDelete: 'CASCADE' });
Task.belongsTo(Student, { foreignKey: 'student_id' });

Student.hasMany(Internship, { foreignKey: 'student_id', onDelete: 'CASCADE' });
Internship.belongsTo(Student, { foreignKey: 'student_id' });

Student.hasMany(Certification, { foreignKey: 'student_id', onDelete: 'CASCADE' });
Certification.belongsTo(Student, { foreignKey: 'student_id' });

Student.hasMany(DocumentRequest, { foreignKey: 'student_id', onDelete: 'CASCADE' });
DocumentRequest.belongsTo(Student, { foreignKey: 'student_id' });

Mentor.hasMany(DocumentRequest, { foreignKey: 'mentor_id', onDelete: 'SET NULL' });
DocumentRequest.belongsTo(Mentor, { foreignKey: 'mentor_id' });

Student.hasMany(Activity, { foreignKey: 'student_id', onDelete: 'CASCADE' });
Activity.belongsTo(Student, { foreignKey: 'student_id' });

Mentor.hasMany(Broadcast, { foreignKey: 'mentor_id', onDelete: 'CASCADE' });
Broadcast.belongsTo(Mentor, { foreignKey: 'mentor_id' });

// Generic relation for notifications could be added, or managed purely by userId
Student.hasMany(Notification, { foreignKey: 'userId', onDelete: 'CASCADE' });
Notification.belongsTo(Student, { foreignKey: 'userId' });
Mentor.hasMany(Notification, { foreignKey: 'userId', onDelete: 'CASCADE' });
Notification.belongsTo(Mentor, { foreignKey: 'userId' });

module.exports = {
  sequelize,
  Mentor,
  Student,
  Activity,
  Broadcast,
  Certification,
  DocumentRequest,
  Internship,
  Meeting,
  Semester,
  SubjectMark,
  Task,
  Notification
};
