// backend\setup-mentor.js
const bcrypt = require('bcrypt');
const { Mentor } = require('./model');

async function createMentor() {
  try {
    const email = 'rais.mulla@pvppcoe.ac.in';
    const password = 'password123'; // Default fallback, we use 12345678 as requested

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash('12345678', saltRounds);

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

    process.exit(0);
  } catch (error) {
    console.error('Error creating mentor:', error);
    process.exit(1);
  }
}

createMentor();
