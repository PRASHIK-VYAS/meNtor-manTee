const { Client } = require('pg');
const dotenv = require('dotenv');
dotenv.config();

const newProjectRef = 'jbmdsjxbkupiewshjmmp';
const password = 'Prashik@2777'; 
const host = 'aws-0-ap-south-1.pooler.supabase.com';

const client = new Client({
  host: host,
  port: 6543,
  user: `postgres.${newProjectRef}`,
  password: password,
  database: 'postgres',
  ssl: { rejectUnauthorized: false }
});

async function test() {
  try {
    console.log(`Testing connection to ${host}...`);
    await client.connect();
    console.log('✅ Success! Connected to new project ID.');
    const res = await client.query('SELECT current_database(), current_user');
    console.log('DB INFO:', res.rows[0]);
    await client.end();
  } catch (err) {
    console.error('❌ Connection failed:', err.message);
    process.exit(1);
  }
}

test();
