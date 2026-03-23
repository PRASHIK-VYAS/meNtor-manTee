const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

const sequelize = new Sequelize(process.env.DATABASE_URL, {
  dialect: 'postgres',
  logging: false,
});

async function resetStudentPassword(email, newPassword) {
  try {
    console.log(`[RESET] Attempting to reset password for student: ${email}`);
    
    // 1. Search in students table
    const [results] = await sequelize.query(`SELECT id FROM students WHERE email = '${email.toLowerCase().trim()}'`);
    
    if (results.length === 0) {
      console.log(`[RESET] ❌ No student found with email: ${email}`);
      return;
    }

    // 2. Update to plain text password
    await sequelize.query(`UPDATE students SET password = '${newPassword}' WHERE email = '${email.toLowerCase().trim()}'`);
    console.log(`[RESET] ✅ Successfully updated password to plain text for ${email}`);
    console.log(`[RESET] You can now log in with password: ${newPassword}`);

  } catch (err) {
    console.error('[RESET] ❌ Error:', err.message);
  } finally {
    await sequelize.close();
  }
}

// Get email from command line or use a default
const email = process.argv[2] || 'krutika1@pvppcoe.ac.in';
resetStudentPassword(email, 'password123');
