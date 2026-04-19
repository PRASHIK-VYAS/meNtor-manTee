const dns = require('dns');

const hosts = [
  'db.wsqbvbcpedonblxbsfdn.supabase.co',
  'aws-0-ap-south-1.pooler.supabase.com',
  'aws-1-ap-southeast-1.pooler.supabase.com'
];

async function checkHosts() {
  for (const host of hosts) {
    try {
      const addresses = await dns.promises.resolve4(host);
      console.log(`✅ ${host}: ${addresses.join(', ')}`);
    } catch (error) {
      console.log(`❌ ${host}: ${error.code}`);
    }
  }
}

checkHosts();
