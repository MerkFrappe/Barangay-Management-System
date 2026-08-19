const { chromium } = require('playwright-core');
const path = require('path');

async function run() {
  console.log('Connecting to Edge on port 9222...');
  const browser = await chromium.connectOverCDP('http://127.0.0.1:9222');
  
  const contexts = browser.contexts();
  console.log(`Found ${contexts.length} context(s).`);
  
  const context = contexts[0];
  const pages = context.pages();
  console.log(`Found ${pages.length} page(s).`);
  
  for (let i = 0; i < pages.length; i++) {
    const page = pages[i];
    const url = page.url();
    const title = await page.title();
    console.log(`Page ${i}: "${title}" - ${url}`);
    
    // Save a screenshot of each page to see what's on screen
    const screenshotPath = path.join(__dirname, `page_${i}.png`);
    await page.screenshot({ path: screenshotPath });
    console.log(`Saved screenshot to ${screenshotPath}`);
  }
  
  await browser.close();
}

run().catch(console.error);
