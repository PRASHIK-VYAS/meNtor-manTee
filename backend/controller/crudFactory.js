const createCrudController = (Model) => {
  const primaryKey = Model.primaryKeyAttribute || 'id';

  return {
    getAll: async (req, res) => {
      try {
        const items = await Model.findAll();
        return res.status(200).json(items);
      } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
      }
    },

    getById: async (req, res) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ message: `${Model.name} not found` });
        }
        return res.status(200).json(item);
      } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
      }
    },

    create: async (req, res) => {
      try {
        const item = await Model.create(req.body);
        return res.status(201).json(item);
      } catch (error) {
        console.error(error);
        return res.status(400).json({ message: error.message });
      }
    },

    update: async (req, res) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ message: `${Model.name} not found` });
        }

        const body = { ...req.body };
        delete body[primaryKey];
        await item.update(body);
        return res.status(200).json(item);
      } catch (error) {
        console.error(error);
        return res.status(400).json({ message: error.message });
      }
    },

    remove: async (req, res) => {
      try {
        const item = await Model.findByPk(req.params.id);
        if (!item) {
          return res.status(404).json({ message: `${Model.name} not found` });
        }

        await item.destroy();
        return res.status(200).json({ message: `${Model.name} deleted successfully` });
      } catch (error) {
        console.error(error);
        return res.status(500).json({ message: 'Internal server error' });
      }
    }
  };
};

module.exports = createCrudController;
