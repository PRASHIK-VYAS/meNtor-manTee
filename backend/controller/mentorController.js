const Mentor = require('../model/mentor');
const Student = require('../model/student');
const Activity = require('../model/activities');
const createCrudController = require('./crudFactory');

const mentorCrud = createCrudController(Mentor);

const getMentorProfile = async (req, res) => {
  try {
    const mentorId = req.user?.id;

    if (!mentorId) {
      return res.status(400).json({ message: 'Mentor id is missing in token' });
    }

    const mentor = await Mentor.findByPk(mentorId);

    if (!mentor) {
      return res.status(404).json({ message: 'Mentor not found' });
    }

    return res.status(200).json(mentor);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const getMentorStudents = async (req, res) => {
  try {
    const students = await Student.findAll({
      where: { mentor_id: req.params.id }
    });

    return res.status(200).json(students);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const getMentorActivities = async (req, res) => {
  try {
    const activities = await Activity.findAll({
      include: [
        {
          model: Student,
          where: { mentor_id: req.params.id },
          required: true
        }
      ]
    });

    return res.status(200).json(activities);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const { Meeting, Broadcast, DocumentRequest } = require('../model');

const getMentorMeetings = async (req, res) => {
  try {
    const meetings = await Meeting.findAll({
      where: { mentor_id: req.params.id }
    });
    return res.status(200).json(meetings);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const getMentorBroadcasts = async (req, res) => {
  try {
    const broadcasts = await Broadcast.findAll({
      where: { mentor_id: req.params.id }
    });
    return res.status(200).json(broadcasts);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const getMentorDocuments = async (req, res) => {
  try {
    const documents = await DocumentRequest.findAll({
      where: { mentor_id: req.params.id }
    });
    return res.status(200).json(documents);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const updateStudentProfile = async (req, res) => {
  try {
    const { studentId } = req.params;
    const mentorId = req.user.id;

    const student = await Student.findOne({
      where: { id: studentId, mentor_id: mentorId }
    });

    if (!student) {
      return res.status(404).json({ message: 'Student not found or not assigned to you' });
    }

    const updates = { ...req.body };
    
    // Mapping for camelCase from frontend
    if (updates.documentStatuses) {
      updates.document_statuses = updates.documentStatuses;
      delete updates.documentStatuses;
    }

    if (updates.documentFilePaths) {
      updates.document_file_paths = updates.documentFilePaths;
      delete updates.documentFilePaths;
    }

    await student.update(updates);
    return res.status(200).json({ message: 'Student profile updated successfully', student });
  } catch (error) {
    console.error('Update Student Profile Error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

module.exports = {
  ...mentorCrud,
  getMentorProfile,
  getMentorStudents,
  getMentorActivities,
  getMentorMeetings,
  getMentorBroadcasts,
  getMentorDocuments,
  updateStudentProfile,
  
  getPendingActivities: async (req, res) => {
    try {
      const { id } = req.params;
      const { Activity, Internship, Certification, Student } = require('../model');
      
      const students = await Student.findAll({ where: { mentor_id: id } });
      const studentIds = students.map(s => s.id);
      
      if (studentIds.length === 0) {
        return res.status(200).json([]);
      }
      
      // Fetch all pending types
      const activities = await Activity.findAll({
        where: { student_id: studentIds, status: 'Pending' },
        include: [{ model: Student, attributes: ['id', 'full_name', 'student_id'] }]
      });

      const internships = await Internship.findAll({
        where: { student_id: studentIds, status: 'Pending' },
        include: [{ model: Student, attributes: ['id', 'full_name', 'student_id'] }]
      });

      const certifications = await Certification.findAll({
        where: { student_id: studentIds, status: 'Pending' },
        include: [{ model: Student, attributes: ['id', 'full_name', 'student_id'] }]
      });
      
      // Combine with type metadata
      const results = [
        ...activities.map(a => ({ ...a.get(), reviewType: 'Activity' })),
        ...internships.map(i => ({ ...i.get(), reviewType: 'Internship' })),
        ...certifications.map(c => ({ ...c.get(), reviewType: 'Certification' }))
      ].sort((a, b) => new Date(b.created_at) - new Date(a.created_at));
      
      return res.status(200).json(results);
    } catch (error) {
      console.error('Error fetching pending activities:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  },
  
  reviewItem: async (req, res) => {
    try {
      const { type, id } = req.params;
      const { status, rejection_reason } = req.body;
      const { Activity, Internship, Certification } = require('../model');
      
      let Model;
      if (type === 'Activity') Model = Activity;
      else if (type === 'Internship') Model = Internship;
      else if (type === 'Certification') Model = Certification;
      else return res.status(400).json({ message: 'Invalid type' });
      
      const item = await Model.findByPk(id);
      if (!item) return res.status(404).json({ message: 'Item not found' });
      
      await item.update({ status, rejection_reason });
      return res.status(200).json(item);
    } catch (error) {
      console.error('Review Item Error:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
};
