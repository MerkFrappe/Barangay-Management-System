import sys, time, os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

LOG = r'D:\BMS\bms\scratch_automate\selenium_result.txt'

def log(msg):
    print(msg)
    with open(LOG, 'a', encoding='utf-8') as f:
        f.write(msg + '\n')

# Clear previous log
with open(LOG, 'w', encoding='utf-8') as f:
    f.write('=== Selenium Firebase Setup Started ===\n')

options = Options()
options.add_argument(r'--user-data-dir=C:\Users\kylej_z264ll1\AppData\Local\Google\Chrome\User Data')
options.add_argument('--profile-directory=Default')
options.add_argument('--no-first-run')
options.add_argument('--no-default-browser-check')
options.add_argument('--disable-sync')
options.add_argument('--no-sandbox')
options.add_argument('--disable-extensions')

log('Starting Chrome with real user profile...')
try:
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    log('Chrome started OK')
except Exception as e:
    log('FAILED to start Chrome: ' + str(e))
    sys.exit(1)

try:
    driver.maximize_window()
    log('Navigating to Firestore console...')
    driver.get('https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore')
    time.sleep(12)
    log('URL: ' + driver.current_url[:100])
    log('Title: ' + driver.title)
    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_session1.png')

    if 'accounts.google.com' in driver.current_url:
        log('ERROR: Redirected to login page - not logged in')
        driver.quit()
        sys.exit(1)

    log('LOGGED IN! Looking for Create database...')
    wait = WebDriverWait(driver, 25)

    try:
        btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'Create database')]")))
        log('Found Create database! Clicking...')
        btn.click()
        time.sleep(4)
        driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_s1_step1.png')
    except Exception as e:
        log('Create database not found: ' + str(e)[:100])
        log('Page body: ' + driver.find_element(By.TAG_NAME, 'body').text[:400])
        driver.quit()
        sys.exit(1)

    try:
        nxt = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(.,'Next')]")))
        nxt.click(); time.sleep(3); log('Clicked Next')
    except: log('No Next button')

    try:
        tm = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'test mode')]")))
        tm.click(); time.sleep(2); log('Selected test mode')
    except: log('No test mode option')

    try:
        en = wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//button[contains(.,'Enable') or contains(.,'Create')]")
        ))
        en.click(); log('Clicked Enable! Firestore provisioning...'); time.sleep(18)
    except Exception as e:
        log('No Enable button: ' + str(e)[:80])

    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_s1_done.png')

    # Now enable Email/Password auth
    log('--- Enabling Email/Password Auth ---')
    driver.get('https://console.firebase.google.com/u/0/project/bms-system-2499a/authentication/providers')
    time.sleep(8)
    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\auth_page.png')

    try:
        gs = driver.find_element(By.XPATH, "//button[contains(.,'Get started')]")
        gs.click(); time.sleep(5); log('Clicked Get started')
    except: pass

    try:
        ep = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'Email/Password')]")))
        ep.click(); time.sleep(3); log('Clicked Email/Password')
    except Exception as e:
        log('Email/Password not found: ' + str(e)[:80])

    try:
        toggles = driver.find_elements(By.CSS_SELECTOR, "input[type='checkbox']")
        if toggles and not toggles[0].is_selected():
            toggles[0].click(); time.sleep(2); log('Enabled toggle')
        elif toggles:
            log('Toggle already enabled')
    except Exception as e:
        log('Toggle error: ' + str(e)[:80])

    try:
        sv = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(.,'Save')]")))
        sv.click(); time.sleep(4); log('Saved!')
    except Exception as e:
        log('Save error: ' + str(e)[:80])

    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\auth_done.png')
    log('=== SETUP COMPLETE ===')

except Exception as e:
    log('Unexpected error: ' + str(e))
finally:
    try: driver.quit()
    except: pass
