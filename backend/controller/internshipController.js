const Internship = require('../model/internshipmodels');
const DocumentRequest = require('../model/documentsmodels');
const Student = require('../model/student');
const createCrudController = require('./crudFactory');

const internshipCrud = createCrudController(Internship);

const getByStudentId = async (req, res) => {
    try {
        const internships = await Internship.findAll({
            where: { student_id: req.params.studentId }
        });
        return res.status(200).json(internships);
    } catch (error) {
        console.error('Error in getByStudentId:', error);
        return res.status(500).json({ 
            message: 'Internal server error',
            error: error.message
        });
    }
};

const create = async (req, res) => {
    try {
        const student = await Student.findByPk(req.body.student_id || req.body.studentId);
        
        const internship = await Internship.create(req.body);

        if (student && student.mentor_id) {
            await DocumentRequest.create({
                student_id: student.id,
                mentor_id: student.mentor_id,
                title: `Internship #${internship.id}: ${internship.role}`,
                description: `Company: ${internship.company} | Duration: ${internship.duration}`,
                type: 'Internship',
                status: 'Pending',
                file_path: internship.certificate_url,
                uploaded_at: new Date()
            });
        }
        
        return res.status(201).json(internship);
    } catch (error) {
        console.error('Error creating internship:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

module.exports = {
    ...internshipCrud,
    getByStudentId,
    create
};
