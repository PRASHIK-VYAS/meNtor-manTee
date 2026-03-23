const { Client } = require('pg');

const projectRefs = ['jbmdsjxbkupiewshjmmp'];
const password = 'Prashik@2777';
const regions = ['ap-south-1', 'ap-southeast-1', 'us-east-1', 'eu-central-1', 'us-west-1', 'us-west-2', 'eu-west-1', 'eu-west-2', 'ap-northeast-1', 'sa-east-1'];
const ports = [6543, 5432];

async function runTests() {
  for (const projectRef of projectRefs) {
    const usernameFormats = [
      'postgres',
      `postgres.${projectRef}`
    ];
    for (const region of regions) {
      for (const port of ports) {
        for (const user of usernameFormats) {
          const host = (port === 6543) 
            ? `aws-0-${region}.pooler.supabase.com`
            : `db.${projectRef}.supabase.co`;
          
          console.log(`Testing: host=${host}, user=${user}, port=${port}`);
          
          const client = new Client({
            user: user,
            host: host,
            database: 'postgres',
            password: password,
            port: port,
            ssl: { rejectUnauthorized: false },
            connectionTimeoutMillis: 3000
          });

          try {
            await client.connect();
            console.log(`>>> SUCCESS: host=${host}, user=${user}, port=${port}`);
            await client.end();
            process.exit(0);
          } catch (err) {
            console.log(`FAILED: ${err.message}`);
          }
        }
      }
    }
  }
  console.log('All tests failed.');
  process.exit(1);
}

runTests();
