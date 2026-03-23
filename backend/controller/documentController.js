const DocumentRequest = require('../model/documentsmodels');
const Certification = require('../model/certificationsmodels');
const Internship = require('../model/internshipmodels');
const Notification = require('../model/notification');
const createCrudController = require('./crudFactory');

const docCrud = createCrudController(DocumentRequest);

const getFilteredDocuments = async (req, res) => {
    try {
        const { userId, role } = req.user;
        const filter = role === 'student' ? { student_id: userId } : { mentor_id: userId };
        const documents = await DocumentRequest.findAll({ where: filter });
        return res.status(200).json(documents);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};

const create = async (req, res) => {
    try {
        const doc = await DocumentRequest.create(req.body);
        
        // Notify the Student if mentor requested a document
        if (doc.status === 'Pending') {
            await Notification.create({
                userId: doc.student_id,
                title: 'New Document Requested',
                message: `Your mentor has requested a new document: ${doc.title}`,
                type: 'DOCUMENT'
            }).catch(e => console.error('Notify Error:', e));
        }
        
        // Notify the Mentor if student uploaded a document independently
        else if (doc.status === 'Pending Approval' && doc.mentor_id) {
            await Notification.create({
                userId: doc.mentor_id,
                title: 'New Document Uploaded',
                message: `A student has uploaded a new document for approval: ${doc.title}`,
                type: 'DOCUMENT'
            }).catch(e => console.error('Notify Error:', e));
        }
        
        return res.status(201).json(doc);
    } catch (error) {
        console.error('Error creating document request:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

const update = async (req, res) => {
    try {
        const doc = await DocumentRequest.findByPk(req.params.id);
        if (!doc) return res.status(404).json({ message: 'Document Request not found' });

        const body = { ...req.body };
        const oldStatus = doc.status;
        await doc.update(body);

        // Notify the Student when mentor approves/rejects
        if (body.status === 'Approved' || body.status === 'Rejected') {
            await Notification.create({
                userId: doc.student_id,
                title: `Document ${body.status}`,
                message: `Your document "${doc.title}" has been ${body.status.toLowerCase()}.`,
                type: 'DOCUMENT'
            });

            const isApproved = body.status === 'Approved';
            
            // Handle specific logic for Certifications/Internships (point assignment/verification)
            if (doc.type === 'Certification' && doc.title.includes('#')) {
                const match = doc.title.match(/#(\d+):/);
                if (match && match[1]) {
                    const certId = match[1];
                    const cert = await Certification.findByPk(certId);
                    if (cert) {
                        let points = 0;
                        if (isApproved) {
                            const typeLower = (cert.type || '').toLowerCase();
                            points = typeLower.includes('external') ? 5 : 1; 
                        }
                        await cert.update({ is_verified: isApproved, points });
                    }
                }
            } else if (doc.type === 'Internship' && doc.title.includes('#')) {
                const match = doc.title.match(/#(\d+):/);
                if (match && match[1]) {
                    const internId = match[1];
                    const intern = await Internship.findByPk(internId);
                    if (intern) {
                        await intern.update({ status: isApproved ? 'Verified' : 'Rejected' });
                    }
                }
            }
        }

        // Notify Mentor when student uploads for a requested document
        if (body.status === 'Uploaded' && oldStatus !== 'Uploaded') {
            await Notification.create({
                userId: doc.mentor_id,
                title: 'Document Submitted',
                message: `A student has submitted the requested document: ${doc.title}`,
                type: 'DOCUMENT'
            });
        }

        return res.status(200).json(doc);
    } catch (error) {
        console.error('Error updating document request:', error);
        return res.status(500).json({ message: 'Internal server error', error: error.message });
    }
};

module.exports = {
    ...docCrud,
    getAll: getFilteredDocuments,
    create,
    update
};
