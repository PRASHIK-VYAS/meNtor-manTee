const net = require('net');

const host = 'db.wsqbvbcpedonblxbsfdn.supabase.co';
const ports = [5432, 6543];

async function checkPort(port) {
  return new Promise((resolve) => {
    const socket = new net.Socket();
    const timeout = 5000;
    
    socket.setTimeout(timeout);
    
    console.log(`Checking ${host}:${port}...`);
    
    socket.on('connect', () => {
      console.log(`✅ ${host}:${port} is REACHABLE`);
      socket.destroy();
      resolve(true);
    });
    
    socket.on('timeout', () => {
      console.log(`❌ ${host}:${port} TIMEOUT after ${timeout}ms`);
      socket.destroy();
      resolve(false);
    });
    
    socket.on('error', (err) => {
      console.log(`❌ ${host}:${port} error: ${err.message}`);
      socket.destroy();
      resolve(false);
    });
    
    socket.connect(port, host);
  });
}

async function run() {
  for (const port of ports) {
    await checkPort(port);
  }
}

run();
