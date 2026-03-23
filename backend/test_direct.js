const { Client } = require('pg');

const client = new Client({
  host: 'db.wsqbvbcpedonblxbsfdn.supabase.co',
  port: 5432,
  user: 'postgres',
  password: 'Prashik%402777',
  database: 'postgres',
  ssl: { rejectUnauthorized: false }
});

async function test() {
  try {
    console.log('Testing DIRECT connection...');
    await client.connect();
    console.log('✅ DIRECT Connection SUCCESS!');
    const res = await client.query('SELECT current_database(), current_user');
    console.log('DB INFO:', res.rows[0]);
    await client.end();
  } catch (err) {
    console.error('❌ DIRECT Connection FAILED:', err.message);
    process.exit(1);
  }
}

test();
