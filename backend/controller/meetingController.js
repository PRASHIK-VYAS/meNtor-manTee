const Meeting = require('../model/meeting');
const Student = require('../model/student'); // Added
const Notification = require('../model/notification'); // Added
const { Op } = require('sequelize'); // Added
const createCrudController = require('./crudFactory');

const meetingCrud = createCrudController(Meeting);

const getByStudentId = async (req, res) => {
    try {
        const studentId = req.params.studentId;

        // 1. Find the student to get their mentor_id
        const student = await Student.findByPk(studentId);
        if (!student) {
            return res.status(404).json({ message: 'Student not found' });
        }

        const mentorId = student.mentor_id;

        // 2. Find meetings that are:
        //    - specifically for this student
        //    - OR are from their mentor and student_id is null (batch-wide)
        const meetings = await Meeting.findAll({
            where: {
                [Op.or]: [
                    { student_id: studentId },
                    {
                        mentor_id: mentorId,
                        student_id: null
                    }
                ]
            },
            order: [['meeting_date', 'DESC'], ['meeting_time', 'DESC']]
        });

        return res.status(200).json(meetings);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const create = async (req, res) => {
    try {
        const meeting = await Meeting.create(req.body);

        // Send notifications
        if (meeting.student_id) {
            // Single student
            await Notification.create({
                userId: meeting.student_id,
                title: 'New Meeting Scheduled',
                message: `A meeting covering "${meeting.meeting_agenda}" was scheduled for ${meeting.meeting_date} at ${meeting.meeting_time}.`,
                type: 'GENERAL'
            }).catch(e => console.error('Notify Error:', e));
        } else if (meeting.mentor_id) {
            // Batch meeting - find all students for this mentor
            const students = await Student.findAll({ where: { mentor_id: meeting.mentor_id } });
            const notifications = students.map(st => ({
                userId: st.id,
                title: 'New Batch Meeting Scheduled',
                message: `A batch meeting for "${meeting.meeting_agenda}" was scheduled for ${meeting.meeting_date} at ${meeting.meeting_time}.`,
                type: 'GENERAL'
            }));
            await Notification.bulkCreate(notifications).catch(e => console.error('Notify Error:', e));
        }

        return res.status(201).json(meeting);
    } catch (error) {
        console.error('Error creating meeting:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

module.exports = {
    ...meetingCrud,
    getByStudentId,
    create
};
