const https = require('https');
const { execSync } = require('child_process');

// Poll auth.firebase.tools to see if the OAuth completed
function fetchUrl(url) {
  return new Promise((resolve) => {
    const req = https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, body: data, headers: res.headers }));
    });
    req.on('error', () => resolve({ status: 0, body: '', headers: {} }));
    req.setTimeout(5000, () => { req.destroy(); resolve({ status: 0, body: '', headers: {} }); });
  });
}

async function waitForAuthCode() {
  console.log('Polling for Firebase CLI auth code...');
  console.log('(Chrome should have the Google OAuth consent page open)\n');
  
  // The session ID from the firebase login --no-localhost output
  const SESSION_ID = 'af61edb1-496d-4566-9231-e70c6c032d58';
  
  for (let i = 0; i < 60; i++) {
    await new Promise(r => setTimeout(r, 3000));
    process.stdout.write(`\rWaiting... ${(i+1)*3}s elapsed`);
    
    // Check if auth completed by trying to fetch the session status
    const res = await fetchUrl(`https://auth.firebase.tools/token?session=${SESSION_ID}`);
    
    if (res.status === 200) {
      console.log('\n\n✓ Auth completed! Response:', res.body.substring(0, 200));
      
      // Extract token
      try {
        const data = JSON.parse(res.body);
        if (data.token || data.access_token || data.code) {
          const token = data.token || data.access_token || data.code;
          console.log('Token/Code:', token);
          require('fs').writeFileSync('firebase_token.txt', token);
          
          // Now complete firebase login
          console.log('\nCompleting firebase login...');
          const result = execSync(`firebase login ${token} --project bms-system-2499a 2>&1`, { encoding: 'utf8' });
          console.log('Login result:', result);
          return token;
        }
      } catch(e) {
        console.log('Raw response:', res.body);
      }
    }
    
    // Also check the auth.firebase.tools/complete endpoint
    const completeRes = await fetchUrl(`https://auth.firebase.tools/complete?session=${SESSION_ID}`);
    if (completeRes.status === 200 && completeRes.body.includes('code')) {
      console.log('\n✓ Completion endpoint responded:', completeRes.body.substring(0, 300));
    }
  }
  
  console.log('\n\nTimeout: auth code not received within 3 minutes.');
  console.log('Please check Chrome - there may be a consent button to click.');
}

waitForAuthCode().catch(console.error);
