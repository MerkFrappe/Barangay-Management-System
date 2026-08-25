const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const outputFile = path.join(__dirname, 'firebase_auth_output2.txt');
if (fs.existsSync(outputFile)) fs.unlinkSync(outputFile);

console.log('Starting firebase login (with localhost callback server)...');

// Run firebase login - it will start a local HTTP server for the OAuth callback
// We set BROWSER to an empty/invalid value so it does NOT try to auto-open the browser
// but still starts the local callback server and prints the URL
const env = {
  ...process.env,
  BROWSER: 'echo', // prevents auto-open but firebase still starts server and prints URL
  FIREBASE_CLI_TELEMETRY_OPTOUT: '1',
};

const firebaseProc = spawn('cmd.exe', ['/c', 'firebase login 2>&1'], { env });

let authUrl = null;
let localPort = null;

firebaseProc.stdout.on('data', (data) => {
  const text = data.toString();
  fs.appendFileSync(outputFile, text);
  process.stdout.write(text);

  // Look for the Google OAuth URL
  const urlMatch = text.match(/(https:\/\/accounts\.google\.com\/o\/oauth2\/auth[^\s\r\n]+)/);
  if (urlMatch && !authUrl) {
    authUrl = urlMatch[0];
    console.log('\n\n✓ Found OAuth URL:', authUrl.substring(0, 80) + '...');

    // Extract the redirect_uri to find what port the local server is on
    const portMatch = authUrl.match(/redirect_uri=http%3A%2F%2Flocalhost%3A(\d+)/);
    if (portMatch) {
      localPort = portMatch[1];
      console.log('✓ Local callback server port:', localPort);
    }

    // Open the URL in Chrome via scheduled task
    try {
      const taskCmd = `schtasks /create /tn "ChromeOAuth" /tr "C:\\PROGRA~1\\Google\\Chrome\\Application\\chrome.exe \\"${authUrl}\\"" /sc once /st 00:00 /sd 01/01/2000 /f`;
      execSync(taskCmd, { stdio: 'ignore' });
      execSync('schtasks /run /tn "ChromeOAuth"');
      console.log('✓ Opened OAuth URL in Chrome! Waiting for callback...');
    } catch (e) {
      console.error('Failed to open Chrome:', e.message);
    }
  }
});

firebaseProc.stderr.on('data', (data) => {
  process.stderr.write(data.toString());
});

firebaseProc.on('close', (code) => {
  console.log(`\nFirebase login process exited with code ${code}`);
  const output = fs.existsSync(outputFile) ? fs.readFileSync(outputFile, 'utf8') : '';
  
  // Check if we got a token
  if (output.includes('Logged in as') || output.includes('Success!')) {
    console.log('\n✓ Firebase login SUCCESSFUL!');
    
    // Now create the Firestore database
    try {
      console.log('\nCreating Firestore database...');
      const result = execSync(
        'firebase firestore:databases:create "(default)" --project bms-system-2499a --location nam5 2>&1',
        { encoding: 'utf8' }
      );
      console.log('Firestore result:', result);
    } catch (e) {
      console.log('Firestore create output:', e.stdout || e.message);
    }
  } else {
    console.log('\nLogin may not have completed. Full output:');
    console.log(output);
  }
});

// 3 minute timeout
setTimeout(() => {
  console.log('\nTimeout reached after 3 minutes.');
  firebaseProc.kill();
}, 180000);
