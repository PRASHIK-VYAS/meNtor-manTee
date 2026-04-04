const https = require('https');

const RENDER_URL = process.env.RENDER_URL || 'https://mentor-mantee.onrender.com/health';

console.log(`[${new Date().toISOString()}] Starting keep-alive ping to: ${RENDER_URL}`);

https.get(RENDER_URL, (res) => {
  const { statusCode } = res;
  console.log(`[${new Date().toISOString()}] Response Status Code: ${statusCode}`);
  
  if (statusCode === 200) {
    console.log('✅ Backend is awake and healthy.');
  } else {
    console.warn(`⚠️ Backend returned non-200 status: ${statusCode}`);
  }
}).on('error', (err) => {
  console.error(`❌ Error pinging backend: ${err.message}`);
});
