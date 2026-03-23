const { Semester, SubjectMark } = require('../model');
const { Op } = require('sequelize');

const toNumber = (value) => {
  const n = Number(value);
  return Number.isFinite(n) ? n : null;
};

const isValidGrade = (value) => Number.isFinite(value) && value >= 0 && value <= 10;

const buildPagination = (query) => {
  const page = Math.max(toNumber(query.page) || 1, 1);
  const limit = Math.min(Math.max(toNumber(query.limit) || 20, 1), 100);
  return { page, limit, offset: (page - 1) * limit };
};

const parseIncludeSubjects = (queryValue) => {
  if (typeof queryValue !== 'string') return false;
  return ['1', 'true', 'yes'].includes(queryValue.toLowerCase());
};

const validateSemesterPayload = (payload, { partial = false } = {}) => {
  const errors = [];
  const requiredFields = ['student_id', 'semester_number', 'sgpa', 'cgpa', 'result_status'];

  if (!partial) {
    requiredFields.forEach((field) => {
      if (payload[field] === undefined || payload[field] === null || payload[field] === '') {
        errors.push(`${field} is required`);
      }
    });
  }

  if (payload.student_id !== undefined && (!Number.isInteger(Number(payload.student_id)) || Number(payload.student_id) < 1)) {
    errors.push('student_id must be a positive integer');
  }

  if (payload.semester_number !== undefined && (!Number.isInteger(Number(payload.semester_number)) || Number(payload.semester_number) < 1)) {
    errors.push('semester_number must be a positive integer');
  }

  if (payload.sgpa !== undefined && !isValidGrade(Number(payload.sgpa))) {
    errors.push('sgpa must be between 0 and 10');
  }

  if (payload.cgpa !== undefined && !isValidGrade(Number(payload.cgpa))) {
    errors.push('cgpa must be between 0 and 10');
  }

  if (payload.result_status !== undefined && String(payload.result_status).trim().length === 0) {
    errors.push('result_status cannot be empty');
  }

  return errors;
};

const safeBody = (payload) => {
  const body = { ...payload };
  delete body.id;
  delete body.created_at;
  delete body.updated_at;
  return body;
};

exports.getAll = async (req, res) => {
  try {
    const { page, limit, offset } = buildPagination(req.query);
    const where = {};

    if (req.query.studentId !== undefined) {
      const studentId = toNumber(req.query.studentId);
      if (!studentId || studentId < 1) {
        return res.status(400).json({ message: 'studentId must be a positive integer' });
      }
      where.student_id = studentId;
    }

    if (req.query.semesterNumber !== undefined) {
      const semesterNumber = toNumber(req.query.semesterNumber);
      if (!semesterNumber || semesterNumber < 1) {
        return res.status(400).json({ message: 'semesterNumber must be a positive integer' });
      }
      where.semester_number = semesterNumber;
    }

    if (req.query.resultStatus) {
      where.result_status = { [Op.like]: `%${String(req.query.resultStatus).trim()}%` };
    }

    const includeSubjects = parseIncludeSubjects(req.query.includeSubjects);
    const include = includeSubjects ? [{ model: SubjectMark, foreignKey: 'semester_id' }] : [];

    const { rows, count } = await Semester.findAndCountAll({
      where,
      include,
      order: [
        ['student_id', 'ASC'],
        ['semester_number', 'ASC']
      ],
      offset,
      limit
    });

    return res.status(200).json({
      data: rows,
      meta: {
        total: count,
        page,
        limit,
        totalPages: Math.ceil(count / limit) || 1
      }
    });
  } catch (error) {
    console.error('getAll semesters error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getById = async (req, res) => {
  try {
    const id = toNumber(req.params.id);
    if (!id || id < 1) {
      return res.status(400).json({ message: 'id must be a positive integer' });
    }

    const includeSubjects = parseIncludeSubjects(req.query.includeSubjects);
    const include = includeSubjects ? [{ model: SubjectMark, foreignKey: 'semester_id' }] : [];
    const semester = await Semester.findByPk(id, { include });

    if (!semester) {
      return res.status(404).json({ message: 'Semester not found' });
    }

    return res.status(200).json(semester);
  } catch (error) {
    console.error('getById semester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getByStudentId = async (req, res) => {
  try {
    const studentId = toNumber(req.params.studentId);
    if (!studentId || studentId < 1) {
      return res.status(400).json({ message: 'studentId must be a positive integer' });
    }

    const semesters = await Semester.findAll({
      where: { student_id: studentId },
      include: [{ model: SubjectMark, foreignKey: 'semester_id' }],
      order: [['semester_number', 'ASC']]
    });

    return res.status(200).json(semesters);
  } catch (error) {
    console.error('getByStudentId semester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

const _syncStudentSemester = async (studentId) => {
  try {
    const { Student } = require('../model');
    const maxSem = await Semester.max('semester_number', { where: { student_id: studentId } });
    if (maxSem) {
      await Student.update({ current_semester: maxSem }, { where: { id: studentId } });
    }
  } catch (err) {
    console.error('Error syncing student semester:', err);
  }
};

exports.create = async (req, res) => {
  try {
    const payload = safeBody(req.body || {});
    const errors = validateSemesterPayload(payload, { partial: false });
    if (errors.length) {
      return res.status(400).json({ message: 'Validation failed', errors });
    }

    const [semester, created] = await Semester.findOrCreate({
      where: {
        student_id: payload.student_id,
        semester_number: payload.semester_number,
      },
      defaults: payload,
    });

    if (!created) {
       await semester.update(payload);
    }
    
    await _syncStudentSemester(payload.student_id);

    return res.status(created ? 201 : 200).json(semester);
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({
        message: 'Semester for this student and semester_number already exists'
      });
    }
    console.error('create semester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.update = async (req, res) => {
  try {
    const id = toNumber(req.params.id);
    if (!id || id < 1) {
      return res.status(400).json({ message: 'id must be a positive integer' });
    }

    const payload = safeBody(req.body || {});
    const errors = validateSemesterPayload(payload, { partial: true });
    if (errors.length) {
      return res.status(400).json({ message: 'Validation failed', errors });
    }

    const semester = await Semester.findByPk(id);
    if (!semester) {
      return res.status(404).json({ message: 'Semester not found' });
    }

    await semester.update(payload);
    await _syncStudentSemester(semester.student_id);
    
    return res.status(200).json(semester);
  } catch (error) {
    if (error.name === 'SequelizeUniqueConstraintError') {
      return res.status(409).json({
        message: 'Semester for this student and semester_number already exists'
      });
    }
    console.error('update semester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.remove = async (req, res) => {
  try {
    const id = toNumber(req.params.id);
    if (!id || id < 1) {
      return res.status(400).json({ message: 'id must be a positive integer' });
    }

    const semester = await Semester.findByPk(id);
    if (!semester) {
      return res.status(404).json({ message: 'Semester not found' });
    }

    await semester.destroy();
    return res.status(200).json({ message: 'Semester deleted successfully' });
  } catch (error) {
    console.error('delete semester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.getSubjectMarksForSemester = async (req, res) => {
  try {
    const semesterId = toNumber(req.params.id);
    if (!semesterId || semesterId < 1) {
      return res.status(400).json({ message: 'id must be a positive integer' });
    }

    const semester = await Semester.findByPk(semesterId);
    if (!semester) {
      return res.status(404).json({ message: 'Semester not found' });
    }

    const marks = await SubjectMark.findAll({
      where: { semester_id: semesterId },
      order: [['subject_name', 'ASC']]
    });

    return res.status(200).json(marks);
  } catch (error) {
    console.error('getSubjectMarksForSemester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};

exports.createSubjectMarkForSemester = async (req, res) => {
  try {
    const semesterId = toNumber(req.params.id);
    if (!semesterId || semesterId < 1) {
      return res.status(400).json({ message: 'id must be a positive integer' });
    }

    const semester = await Semester.findByPk(semesterId);
    if (!semester) {
      return res.status(404).json({ message: 'Semester not found' });
    }

    const payload = { ...req.body, semester_id: semesterId };
    delete payload.id;
    delete payload.created_at;
    delete payload.updated_at;

    if (!payload.subject_name || String(payload.subject_name).trim().length === 0) {
      return res.status(400).json({ message: 'subject_name is required' });
    }

    if (payload.ia1 !== undefined && Number(payload.ia1) < 0) {
      return res.status(400).json({ message: 'ia1 cannot be negative' });
    }

    if (payload.ia2 !== undefined && Number(payload.ia2) < 0) {
      return res.status(400).json({ message: 'ia2 cannot be negative' });
    }

    const mark = await SubjectMark.create(payload);
    return res.status(201).json(mark);
  } catch (error) {
    console.error('createSubjectMarkForSemester error:', error);
    return res.status(500).json({ message: 'Internal server error' });
  }
};
