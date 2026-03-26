const Broadcast = require('../model/broadcastmodels');
const { Student, Notification } = require('../model');
const createCrudController = require('./crudFactory');

const baseCrud = createCrudController(Broadcast);

const create = async (req, res) => {
    try {
        const broadcast = await Broadcast.create(req.body);
        
        // Notify all students (or specific ones if filtered, but usually broadcasts are for all)
        const students = await Student.findAll({ where: { mentor_id: broadcast.mentor_id } });
        
        for (const student of students) {
            await Notification.create({
                userId: student.id,
                title: 'New Announcement',
                message: broadcast.title,
                type: 'BROADCAST'
            }).catch(e => console.error('Broadcast Notify Error:', e));
        }
        
        return res.status(201).json(broadcast);
    } catch (error) {
        console.error('Broadcast Creation Error:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const getByMentorId = async (req, res) => {
    try {
        const broadcasts = await Broadcast.findAll({
            where: { mentor_id: req.params.mentorId },
            order: [['createdAt', 'DESC']]
        });
        return res.status(200).json(broadcasts);
    } catch (error) {
        console.error('Error fetching broadcasts:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

module.exports = {
    ...baseCrud,
    create,
    getByMentorId
};
