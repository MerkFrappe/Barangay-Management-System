const { chromium } = require('playwright-core');

async function signIntoGoogle(page) {
  console.log('Handling Google sign-in...');
  await page.waitForTimeout(3000);
  await page.screenshot({ path: 'signin1.png' });

  // Enter email
  try {
    await page.evaluate(() => {
      const inputs = document.querySelectorAll('input');
      for (const inp of inputs) {
        if (inp.type === 'email' || inp.id === 'identifierId' || inp.name === 'identifier') {
          inp.focus();
          inp.value = 'kylejoshua878@gmail.com';
          inp.dispatchEvent(new Event('input', { bubbles: true }));
          inp.dispatchEvent(new Event('change', { bubbles: true }));
          return true;
        }
      }
      return false;
    });
    console.log('Filled email via JS');
    await page.waitForTimeout(1000);

    // Click Next
    await page.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) {
        if (btn.textContent.trim() === 'Next') { btn.click(); return; }
      }
      const next = document.getElementById('identifierNext');
      if (next) next.click();
    });
    console.log('Clicked Next after email');
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'signin2.png' });
  } catch(e) {
    console.log('Email fill error:', e.message.substring(0, 100));
  }

  // Enter password
  try {
    const passwordFilled = await page.evaluate(() => {
      const pwds = document.querySelectorAll('input[type="password"]');
      if (pwds.length > 0) {
        pwds[0].focus();
        pwds[0].value = 'MariaAntonia878#';
        pwds[0].dispatchEvent(new Event('input', { bubbles: true }));
        pwds[0].dispatchEvent(new Event('change', { bubbles: true }));
        return true;
      }
      return false;
    });
    
    if (passwordFilled) {
      console.log('Filled password via JS');
      await page.waitForTimeout(1000);
      
      // Click Next
      await page.evaluate(() => {
        const btns = document.querySelectorAll('button');
        for (const btn of btns) {
          if (btn.textContent.trim() === 'Next') { btn.click(); return; }
        }
        const next = document.getElementById('passwordNext');
        if (next) next.click();
      });
      console.log('Clicked Next after password');
      await page.waitForTimeout(6000);
      await page.screenshot({ path: 'signin3.png' });
    } else {
      console.log('Password field not found!');
    }
  } catch (e) {
    console.log('Password fill error:', e.message.substring(0, 100));
  }

  // Check if login succeeded
  for (let i = 0; i < 15; i++) {
    if (!page.url().includes('accounts.google.com')) break;
    await page.waitForTimeout(2000);
  }
  
  console.log('Final URL after login attempt:', page.url().substring(0, 100));
  return !page.url().includes('accounts.google.com');
}

async function setupFirestore(context) {
  console.log('\n--- Creating Firestore Database ---');
  const fsPage = await context.newPage();
  await fsPage.goto('https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore', { waitUntil: 'domcontentloaded' });
  await fsPage.waitForTimeout(10000);
  await fsPage.screenshot({ path: 'firestore_setup.png' });

  const bodyText = await fsPage.evaluate(() => document.body.innerText);
  console.log('Firestore page text snippet:', bodyText.substring(0, 300));

  if (bodyText.includes('Create database')) {
    console.log('Found "Create database" button!');
    await fsPage.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) {
        if (btn.textContent.includes('Create database')) { btn.click(); return; }
      }
    });
    await fsPage.waitForTimeout(5000);
    await fsPage.screenshot({ path: 'fs_step1.png' });

    // Next
    await fsPage.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) { if (btn.textContent.trim() === 'Next') { btn.click(); return; } }
    });
    await fsPage.waitForTimeout(4000);

    // Test mode
    await fsPage.evaluate(() => {
      const els = document.querySelectorAll('*');
      for (const el of els) {
        if (el.textContent.includes('test mode') && el.tagName !== 'BODY') { el.click(); return; }
      }
    });
    await fsPage.waitForTimeout(3000);

    // Enable
    await fsPage.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) {
        if (btn.textContent.includes('Enable') || btn.textContent.includes('Create')) { btn.click(); return; }
      }
    });
    console.log('Clicked Enable - Firestore provisioning...');
    await fsPage.waitForTimeout(25000);
    await fsPage.screenshot({ path: 'fs_done.png' });
    console.log('Firestore setup done!');
  } else if (bodyText.includes('Cloud Firestore') && !bodyText.includes('Create database')) {
    console.log('Firestore already exists!');
  } else {
    console.log('Unexpected state. Check firestore_setup.png');
  }
}

async function setupAuth(context) {
  console.log('\n--- Enabling Email/Password Auth ---');
  const authPage = await context.newPage();
  await authPage.goto('https://console.firebase.google.com/u/0/project/bms-system-2499a/authentication/providers', { waitUntil: 'domcontentloaded' });
  await authPage.waitForTimeout(10000);
  await authPage.screenshot({ path: 'auth_setup.png' });

  const bodyText = await authPage.evaluate(() => document.body.innerText);
  
  if (bodyText.includes('Get started')) {
    await authPage.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) { if (btn.textContent.includes('Get started')) { btn.click(); return; } }
    });
    await authPage.waitForTimeout(5000);
  }

  const newBody = await authPage.evaluate(() => document.body.innerText);
  if (newBody.includes('Email/Password')) {
    await authPage.evaluate(() => {
      const els = [...document.querySelectorAll('*')];
      const el = els.find(e => e.children.length < 3 && e.textContent.trim() === 'Email/Password');
      if (el) el.click();
    });
    await authPage.waitForTimeout(3000);

    const checked = await authPage.evaluate(() => {
      const cb = document.querySelector('input[type="checkbox"]');
      if (cb && !cb.checked) { cb.click(); return true; }
      return cb ? cb.checked : false;
    });
    console.log('Toggle checked:', checked);
    await authPage.waitForTimeout(1500);

    await authPage.evaluate(() => {
      const btns = document.querySelectorAll('button');
      for (const btn of btns) { if (btn.textContent.includes('Save')) { btn.click(); return; } }
    });
    await authPage.waitForTimeout(4000);
    console.log('Auth saved!');
  } else {
    console.log('Email/Password row not found. Body:', newBody.substring(0, 200));
  }
}

async function run() {
  console.log('Starting Edge with Playwright...');
  
  const browser = await chromium.launch({
    executablePath: 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
    headless: false, // Run headful just to be sure Google doesn't block it
    args: ['--window-size=1280,720']
  });
  
  const context = await browser.newContext({ viewport: { width: 1280, height: 720 } });
  const page = await context.newPage();

  console.log('Navigating to Firebase console...');
  await page.goto('https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore', { waitUntil: 'domcontentloaded' });
  await page.waitForTimeout(8000);
  console.log('URL:', page.url().substring(0, 100));

  if (page.url().includes('accounts.google.com')) {
    const loggedIn = await signIntoGoogle(page);
    if (!loggedIn) {
      console.log('Could not log in automatically. Exiting.');
      await browser.close();
      return;
    }
    await page.goto('https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore', { waitUntil: 'domcontentloaded' });
    await page.waitForTimeout(10000);
  }

  console.log('Firebase console accessible!');
  await setupAuth(context);
  await setupFirestore(context);

  await browser.close();
  console.log('\n=== SETUP COMPLETE ===');
}

run().catch(e => { console.error('Fatal:', e.message); process.exit(1); });
