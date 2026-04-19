// backend\clear_dummy_data.js
const { 
  sequelize, 
  Activity, 
  DocumentRequest, 
  Internship, 
  Certification, 
  Task, 
  Semester, 
  SubjectMark,
  Student
} = require('./model');

async function clearDummyData() {
  try {
    console.log('--- STARTING DATABASE CLEANUP ---');
    
    // 1. Delete all student-submitted records
    console.log('Clearing Activities...');
    await Activity.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Document Requests...');
    await DocumentRequest.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Internships...');
    await Internship.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Certifications...');
    await Certification.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Tasks...');
    await Task.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Subject Marks...');
    await SubjectMark.destroy({ where: {}, truncate: false });
    
    console.log('Clearing Semesters...');
    await Semester.destroy({ where: {}, truncate: false });
    
    // 2. Reset student profile flags
    console.log('Resetting Student document statuses and paths...');
    await Student.update(
      { 
        document_statuses: {}, 
        document_file_paths: {} 
      }, 
      { where: {} }
    );

    console.log('--- CLEANUP COMPLETE ---');
    console.log('All dummy data removed. Student accounts preserved.');
    process.exit(0);
  } catch (error) {
    console.error('CRITICAL ERROR DURING CLEANUP:', error);
    process.exit(1);
  }
}

clearDummyData();
