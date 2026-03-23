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
      const { Activity, Student } = require('../model');
      
      const students = await Student.findAll({ where: { mentor_id: id } });
      const studentIds = students.map(s => s.id);
      
      if (studentIds.length === 0) {
        return res.status(200).json([]);
      }
      
      const activities = await Activity.findAll({
        where: {
          student_id: studentIds,
          is_verified: false
        },
        include: [{
          model: Student,
          attributes: ['id', 'full_name', 'student_id']
        }],
        order: [['created_at', 'DESC']]
      });
      
      return res.status(200).json(activities);
    } catch (error) {
      console.error('Error fetching pending activities:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  },
  
  approveActivity: async (req, res) => {
    try {
      const { activityId } = req.params;
      const { is_verified } = req.body;
      const { Activity } = require('../model');
      
      const activity = await Activity.findByPk(activityId);
      if (!activity) {
        return res.status(404).json({ message: 'Activity not found' });
      }
      
      await activity.update({ is_verified });
      return res.status(200).json(activity);
    } catch (error) {
      console.error('Approve Activity Error:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
};
