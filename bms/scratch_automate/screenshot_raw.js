const WebSocket = require('ws');
const fs = require('fs');

function captureScreenshot(wsUrl, filename) {
  return new Promise((resolve, reject) => {
    console.log(`Connecting to ${wsUrl}...`);
    const ws = new WebSocket(wsUrl);
    ws.on('open', () => {
      console.log('Connected! Sending Page.captureScreenshot command...');
      const message = JSON.stringify({
        id: 1,
        method: 'Page.captureScreenshot',
        params: { format: 'png' }
      });
      ws.send(message);
    });
    ws.on('message', (data) => {
      try {
        const response = JSON.parse(data);
        if (response.id === 1 && response.result && response.result.data) {
          const buffer = Buffer.from(response.result.data, 'base64');
          fs.writeFileSync(filename, buffer);
          console.log(`Screenshot saved to ${filename}!`);
          ws.close();
          resolve();
        } else {
          // Ignore other browser event messages
        }
      } catch (e) {
        console.error('Error parsing message:', e);
      }
    });
    ws.on('error', (err) => {
      console.error('WebSocket error:', err);
      reject(err);
    });
  });
}

async function run() {
  await captureScreenshot('ws://127.0.0.1:9222/devtools/page/27D9F35DE6F80C5ACDD8564F3FA3758D', 'page_google.png');
}

run().catch(console.error);
