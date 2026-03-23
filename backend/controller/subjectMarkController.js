const SubjectMark = require('../model/subject_marks');
const createCrudController = require('./crudFactory');

module.exports = createCrudController(SubjectMark);
