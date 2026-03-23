const Task = require('../model/tasks');
const createCrudController = require('./crudFactory');

const taskCrud = createCrudController(Task);
const { Student } = require('../model');

const getByStudentId = async (req, res) => {
    try {
        const tasks = await Task.findAll({
            where: { student_id: req.params.studentId }
        });
        return res.status(200).json(tasks);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const createBulk = async (req, res) => {
    try {
        const { studentIds, ...taskData } = req.body;
        if (!studentIds || !Array.isArray(studentIds)) {
            return res.status(400).json({ message: 'studentIds must be an array' });
        }

        const tasksToCreate = studentIds.map(studentId => ({
            ...taskData,
            student_id: studentId
        }));

        const createdTasks = await Task.bulkCreate(tasksToCreate);

        // Notify each student about the new task
        for (const studentId of studentIds) {
            await Notification.create({
                userId: studentId,
                title: 'New Task Assigned',
                message: `You have been assigned a new task: ${taskData.title}`,
                type: 'TASK'
            }).catch(e => console.error('Notify Error:', e));
        }

        return res.status(201).json(createdTasks);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const { Notification, Mentor } = require('../model');

const update = async (req, res) => {
    try {
        const task = await Task.findByPk(req.params.id);
        if (!task) return res.status(404).json({ message: 'Task not found' });

        const oldStatus = task.status;
        const body = { ...req.body };
        
        // Handle audit timestamps
        if (body.status === 'Submitted' && oldStatus !== 'Submitted') {
            body.submitted_at = new Date();
        } else if (body.status === 'Reviewed' && oldStatus !== 'Reviewed') {
            body.reviewed_at = new Date();
        }

        await task.update(body);

        // If student submitted task, notify mentor
        if (body.status === 'Submitted' && oldStatus !== 'Submitted') {
            try {
                const student = await Student.findByPk(task.student_id);
                if (student && student.mentor_id) {
                    await Notification.create({
                        userId: student.mentor_id,
                        title: 'Task Submitted',
                        message: `Student ${student.full_name} has submitted task: ${task.title}`,
                        type: 'TASK'
                    });
                }
            } catch (notifyError) {
                console.error('Failed to create notification:', notifyError);
            }
        }

        // If mentor reviewed task, notify student
        if (body.status === 'Reviewed' && oldStatus !== 'Reviewed') {
            await Notification.create({
                userId: task.student_id,
                title: 'Task Reviewed',
                message: `Your task "${task.title}" has been reviewed by your mentor.`,
                type: 'TASK'
            }).catch(e => console.error('Notify Error:', e));
        }

        return res.status(200).json(task);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

module.exports = {
    ...taskCrud,
    getByStudentId,
    createBulk,
    update
};
