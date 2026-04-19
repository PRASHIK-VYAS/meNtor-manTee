const dns = require('dns');

const hosts = [
  'wsqbvbcpedonblxbsfdn.supabase.co',
  'api.wsqbvbcpedonblxbsfdn.supabase.co',
  'db.wsqbvbcpedonblxbsfdn.supabase.co'
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
