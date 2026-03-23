// backend\controller\certificationController.js
const Certification = require('../model/certificationsmodels');
const DocumentRequest = require('../model/documentsmodels');
const Student = require('../model/student');
const createCrudController = require('./crudFactory');

const certCrud = createCrudController(Certification);

const getByStudentId = async (req, res) => {
    try {
        const certs = await Certification.findAll({
            where: { student_id: req.params.studentId }
        });
        return res.status(200).json(certs);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const create = async (req, res) => {
    try {
        const student = await Student.findByPk(req.body.student_id || req.body.studentId);
        
        const cert = await Certification.create(req.body);

        if (student && student.mentor_id) {
            await DocumentRequest.create({
                student_id: student.id,
                mentor_id: student.mentor_id,
                title: `Certification #${cert.id}: ${cert.title}`,
                description: `Issuer: ${cert.issuer} | Category: ${cert.category} | Type: ${cert.type}`,
                type: 'Certification',
                status: 'Pending',
                file_path: cert.certificate_url,
                uploaded_at: new Date()
            });
        }
        
        return res.status(201).json(cert);
    } catch (error) {
        console.error('Error creating certification:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

const update = async (req, res) => {
    try {
        const cert = await Certification.findByPk(req.params.id);
        if (!cert) return res.status(404).json({ message: 'Certification not found' });

        const body = { ...req.body };
        
        // Handle Point Scoring
        if (body.is_verified === true && cert.is_verified !== true) {
            // Give points based on category (Internal = 1, External = 5)
            const categoryLower = (cert.category || body.category || '').toLowerCase();
            if (categoryLower.includes('internal')) {
                body.points = 1;
            } else if (categoryLower.includes('external')) {
                body.points = 5;
            } else {
                body.points = 1; // Default
            }
        } else if (body.is_verified === false) {
            body.points = 0;
        }

        await cert.update(body);
        return res.status(200).json(cert);
    } catch (error) {
         console.error('Error updating certification:', error);
         return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

module.exports = {
    ...certCrud,
    getByStudentId,
    create,
    update
};
