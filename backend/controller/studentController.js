const { Student, Semester, Certification, Internship, Task, Meeting, SubjectMark } = require('../model');
const createCrudController = require('./crudFactory');

const studentCrud = createCrudController(Student);

module.exports = {
  ...studentCrud,
  getStudentProfileById: async (req, res) => {
    try {
      console.log(`[DEBUG PROFILE] Fetching profile for ID: ${req.params.studentId}`);
      const student = await Student.findByPk(req.params.studentId, {
        include: [
          {
            model: Semester,
            include: [{ model: SubjectMark }]
          },
          { model: Certification },
          { model: Internship },
          { model: Task },
          { model: Meeting }
        ],
        order: [
          ['created_at', 'DESC']
        ]
      });

      console.log(`[DEBUG PROFILE] Profile found: ${student ? 'YES' : 'NO'}`);
      if (!student) {
        return res.status(404).json({ message: 'Student not found' });
      }

      return res.status(200).json(student);
    } catch (error) {
      console.error('Error fetching student profile:', error);
      return res.status(500).json({ message: 'Internal server error', error: error.message, stack: error.stack });
    }
  },

  getLeaderboard: async (req, res) => {
    try {
      const { mentorId } = req.query;
      const queryOptions = {
        where: {},
        include: [
          { model: Semester, required: false },
          { model: Certification, required: false },
          { model: Internship, required: false },
          { model: Task, required: false },
          { model: Meeting, required: false }
        ]
      };
      
      if (mentorId) {
        queryOptions.where.mentor_id = mentorId;
      }
      
      const students = await Student.findAll(queryOptions);
      
      const leaderboard = students.map(student => {
        let currentCGPA = 0;
        if (student.Semesters && student.Semesters.length > 0) {
          const sorted = student.Semesters.sort((a, b) => b.semester_number - a.semester_number);
          currentCGPA = sorted[0].cgpa > 0 ? sorted[0].cgpa : sorted[0].sgpa;
        }
        
        let cgpaScore = (currentCGPA / 10.0) * 50;
        
        const verifiedCerts = student.Certifications ? student.Certifications.filter(c => c.is_verified) : [];
        const certPoints = verifiedCerts.reduce((sum, c) => sum + (c.points || 0), 0);
        let certScore = Math.min(certPoints, 10);
        
        const internshipCount = student.Internships ? student.Internships.length : 0;
        let internshipScore = Math.min(internshipCount * 10, 20);
        
        const completedTasksCount = student.Tasks ? student.Tasks.filter(t => t.status === 'Completed').length : 0;
        const taskScore = Math.min(completedTasksCount * 2, 20);
        
        const attendedMeetingsCount = student.Meetings ? student.Meetings.filter(m => m.status === 'Completed' || m.status === 'Attended').length : 0;
        const meetingScore = Math.min(attendedMeetingsCount * 2, 10);
        
        const totalScore = Math.round((cgpaScore + certScore + internshipScore + taskScore + meetingScore) * 10) / 10;
        
        return {
          id: student.id,
          fullName: student.full_name,
          currentCGPA,
          certificationsCount: verifiedCerts.length,
          internshipsCount: internshipCount,
          completedTasksCount,
          attendedMeetingsCount,
          totalScore
        };
      });
      
      leaderboard.sort((a, b) => b.totalScore - a.totalScore);
      
      return res.status(200).json(leaderboard);
    } catch (error) {
      console.error('Error fetching leaderboard:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
};
