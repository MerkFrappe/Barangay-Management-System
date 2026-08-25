const OAUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth?access_type=offline&client_id=563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com&code_challenge=KUofVu3kR7dGgkYSRQ_ZV3RrVEOl5cXgJdPBqMbPqgQ&code_challenge_method=S256&prompt=select_account+consent&redirect_uri=https%3A%2F%2Fauth.firebase.tools%2Fcomplete&response_type=code&scope=email+openid+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Ffirebase+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloud-platform+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fcloudplatformprojects.readonly&state=af61edb1-496d-4566-9231-e70c6c032d58';

const { execSync } = require('child_process');

// Open the OAuth URL in Chrome via schtasks
try {
  // Use short URL without quotes issues - write it to a temp bat file
  const fs = require('fs');
  const batContent = `@echo off\n"C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" "${OAUTH_URL}"\n`;
  fs.writeFileSync('open_oauth.bat', batContent);
  
  execSync('schtasks /create /tn "OpenOAuth" /tr "D:\\BMS\\bms\\scratch_automate\\open_oauth.bat" /sc once /st 00:00 /sd 01/01/2000 /f', { stdio: 'pipe' });
  execSync('schtasks /run /tn "OpenOAuth"');
  console.log('Opened OAuth URL in Chrome!');
} catch(e) {
  console.error('Error:', e.message);
}
