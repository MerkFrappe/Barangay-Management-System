const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const http = require('http');

// Step 1: Start firebase login --no-localhost and capture the URL
console.log('Starting firebase login --no-localhost...');

const outputFile = path.join(__dirname, 'firebase_auth_output.txt');
const firebaseProc = spawn(
  'cmd.exe',
  ['/c', 'firebase login --no-localhost 2>&1'],
  { env: { ...process.env, FIREBASE_CLI_TELEMETRY_OPTOUT: '1' } }
);

let authUrl = null;
let fullOutput = '';

firebaseProc.stdout.on('data', (data) => {
  const text = data.toString();
  fullOutput += text;
  fs.appendFileSync(outputFile, text);
  process.stdout.write(text);
  
  // Look for the auth URL
  const urlMatch = text.match(/https:\/\/accounts\.google\.com[^\s]+/);
  if (urlMatch && !authUrl) {
    authUrl = urlMatch[0];
    console.log('\n\nFound auth URL:', authUrl);
    
    // Step 2: Open the URL in Chrome via schtasks
    const escapedUrl = authUrl.replace(/&/g, '^&');
    try {
      // Update the schtasks task to open this specific URL
      execSync(`schtasks /create /tn "ChromeAuthURL" /tr "C:\\PROGRA~1\\Google\\Chrome\\Application\\chrome.exe ${authUrl}" /sc once /st 00:00 /sd 01/01/2000 /f 2>nul`);
      execSync('schtasks /run /tn "ChromeAuthURL"');
      console.log('Opened auth URL in Chrome via scheduled task!');
    } catch (e) {
      console.error('Failed to open in Chrome:', e.message);
    }
  }
});

firebaseProc.stderr.on('data', (data) => {
  process.stderr.write(data.toString());
});

firebaseProc.on('close', (code) => {
  console.log(`\nFirebase process exited with code ${code}`);
  console.log('Full output saved to:', outputFile);
});

// Give it 120 seconds max
setTimeout(() => {
  firebaseProc.kill();
  console.log('Timeout reached.');
}, 120000);
