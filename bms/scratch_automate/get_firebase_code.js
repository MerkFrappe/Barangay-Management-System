const WebSocket = require('ws');
const http = require('http');
const { execSync } = require('child_process');
const fs = require('fs');

const AUTH_URL = 'https://auth.firebase.tools/login?code_challenge=KUofVu3kR7dGgkYSRQ_ZV3RrVEOl5cXgJdPBqMbPqgQ&session=af61edb1-496d-4566-9231-e70c6c032d58&attest=Nl1BomZ_uqLE1wU-rsmeibHq-H0sxbQICr8leuviuyI';

function getJson(url) {
  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => { try { resolve(JSON.parse(data)); } catch(e) { resolve({}); } });
    }).on('error', reject);
  });
}

function sendCDP(wsUrl, method, params = {}) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl);
    let resolved = false;
    ws.on('open', () => ws.send(JSON.stringify({ id: 1, method, params })));
    ws.on('message', (data) => {
      const msg = JSON.parse(data);
      if (msg.id === 1 && !resolved) {
        resolved = true;
        ws.close();
        resolve(msg.result);
      }
    });
    ws.on('error', reject);
    setTimeout(() => { if (!resolved) { resolved = true; ws.close(); reject(new Error('timeout')); } }, 8000);
  });
}

async function getPageText(wsUrl) {
  const result = await sendCDP(wsUrl, 'Runtime.evaluate', {
    expression: 'document.body.innerText',
    returnByValue: true
  });
  return result && result.result ? result.result.value : '';
}

async function navigate(wsUrl, url) {
  return sendCDP(wsUrl, 'Page.navigate', { url });
}

async function main() {
  console.log('Step 1: Opening Firebase auth URL in Chrome via scheduled task...');
  try {
    execSync(`schtasks /create /tn "ChromeGetCode" /tr "C:\\PROGRA~1\\Google\\Chrome\\Application\\chrome.exe \\"${AUTH_URL}\\"" /sc once /st 00:00 /sd 01/01/2000 /f`, { stdio: 'ignore' });
    execSync('schtasks /run /tn "ChromeGetCode"');
    console.log('✓ Chrome opened with auth URL');
  } catch(e) {
    console.error('schtasks failed:', e.message);
  }

  // Wait for Chrome to load
  console.log('Waiting 8 seconds for Chrome to load the page...');
  await new Promise(r => setTimeout(r, 8000));

  // Step 2: Check if debug port is available
  console.log('Step 2: Checking CDP port 9222...');
  let tabs;
  try {
    tabs = await getJson('http://127.0.0.1:9222/json');
    console.log(`✓ Found ${tabs.length} tabs`);
  } catch(e) {
    console.log('✗ Port 9222 not accessible. Chrome was not launched with --remote-debugging-port.');
    console.log('\n--- FALLBACK: Reading auth page via HTTP fetch ---');
    
    // Try to fetch the auth page content ourselves to see what it says
    const https = require('https');
    https.get(AUTH_URL, (res) => {
      let d = '';
      res.on('data', c => d += c);
      res.on('end', () => {
        // Look for auth code patterns
        const codeMatch = d.match(/authorization[_\s]code["\s:]+([A-Za-z0-9_\-]{20,})/i)
                       || d.match(/code["\s:]+([A-Za-z0-9_\-]{40,})/i);
        if (codeMatch) {
          console.log('Found code:', codeMatch[1]);
        } else {
          // Save page for inspection
          fs.writeFileSync('auth_page.html', d);
          console.log('Page saved to auth_page.html for inspection');
          console.log('Page snippet:', d.substring(0, 500));
        }
      });
    }).on('error', e => console.error('Fetch error:', e));
    return;
  }

  // Find the Firebase auth tab
  const authTab = tabs.find(t => t.url && (t.url.includes('firebase.tools') || t.url.includes('accounts.google')));
  if (!authTab) {
    console.log('Available tabs:');
    tabs.forEach(t => console.log(' -', t.title, '|', t.url));
    return;
  }

  console.log('✓ Found auth tab:', authTab.title, '|', authTab.url);
  const wsUrl = authTab.webSocketDebuggerUrl;

  // Wait for page content and read auth code
  console.log('Reading page text...');
  await new Promise(r => setTimeout(r, 3000));
  const text = await getPageText(wsUrl);
  console.log('Page text:', text.substring(0, 500));

  // Look for auth code
  const codeMatch = text.match(/[0-9a-f]{40,}/i) || text.match(/auth.?code[:\s]+([A-Za-z0-9_\-]{10,})/i);
  if (codeMatch) {
    const code = codeMatch[1] || codeMatch[0];
    console.log('\n✓ Auth code found:', code);
    fs.writeFileSync('firebase_auth_code.txt', code);
    console.log('Code saved to firebase_auth_code.txt');
  } else {
    console.log('No auth code found yet. Full page text:');
    console.log(text);
    fs.writeFileSync('firebase_auth_page.txt', text);
  }
}

main().catch(console.error);
