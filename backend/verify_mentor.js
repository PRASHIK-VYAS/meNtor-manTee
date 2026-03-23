const { Sequelize } = require('sequelize');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
});

async function checkSpecificMentor(email) {
  try {
    const [results] = await sequelize.query(`SELECT password FROM mentors WHERE email = '${email}'`);
    if (results.length > 0) {
      const match = await bcrypt.compare('password123', results[0].password);
      console.log(`[VERIFY] Password for ${email} matches "password123":`, match);
    }
  } catch (err) {
    console.error('[VERIFY] Error:', err.message);
  } finally {
    await sequelize.close();
  }
}

checkSpecificMentor('mentor@pvppcoe.ac.in');
