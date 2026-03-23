const Activity = require('../model/activities');
const createCrudController = require('./crudFactory');

const baseController = createCrudController(Activity);

module.exports = {
  ...baseController,
  getByStudentId: async (req, res) => {
    try {
      const items = await Activity.findAll({ where: { student_id: req.params.id } });
      return res.status(200).json(items);
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  },
  create: async (req, res) => {
    try {
      if (req.body.id === "" || req.body.id === null) {
        delete req.body.id;
      }
      return baseController.create(req, res);
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
};
