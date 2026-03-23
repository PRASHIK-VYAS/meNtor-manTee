const { Client } = require('pg');
const dotenv = require('dotenv');
dotenv.config();

const client = new Client({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false
  }
});

async function test() {
  try {
    console.log('Connecting to:', process.env.DATABASE_URL);
    await client.connect();
    console.log('SUCCESS: Connected to PostgreSQL.');
    const res = await client.query('SELECT current_database(), current_user');
    console.log('DB INFO:', res.rows[0]);
    await client.end();
    process.exit(0);
  } catch (err) {
    console.error('FAILURE:');
    console.error(err);
    process.exit(1);
  }
}

test();
