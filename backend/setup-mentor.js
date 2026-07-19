// backend\setup-mentor.js
const bcrypt = require('bcrypt');
const { sequelize, Mentor } = require('./model');
const { testDatabaseConnection } = require('./config/database');

async function createMentor() {
  try {
    const email = 'rais.mulla@pvppcoe.ac.in';
    const password = '12345678';

    

    await testDatabaseConnection();
    await sequelize.sync({ alter: true });

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    const [mentor, created] = await Mentor.findOrCreate({
      where: { email: email },
      defaults: {
        full_name: 'Rais Mulla',
        email: email,
        password: hashedPassword,
        department: 'CSE',
        mentor_code: 'RM-CSE-001',
        phone_number: '0000000000',
        role: 'mentor'
      }
    });

    if (created) {
      console.log(`Mentor ${email} created successfully.`);
    } else {
      console.log(`Mentor ${email} already exists. Updating password...`);
      mentor.password = hashedPassword;
      await mentor.save();
      console.log(`Password updated for ${email}.`);
    }

  } catch (error) {
    console.error('Error creating mentor:', error);
    process.exit(1);
  } finally {
    await sequelize.close();
  }
}

createMentor();
