import sys, time, shutil, os
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager

# Copy essential Chrome profile files to a temp location
src = r'C:\Users\kylej_z264ll1\AppData\Local\Google\Chrome\User Data\Default'
tmp = r'D:\BMS\bms\scratch_automate\chrome_tmp'
tmp_default = os.path.join(tmp, 'Default')

if os.path.exists(tmp):
    shutil.rmtree(tmp, ignore_errors=True)
os.makedirs(tmp_default, exist_ok=True)

for item in ['Cookies', 'Network', 'Login Data', 'Web Data', 'Preferences']:
    s = os.path.join(src, item)
    d = os.path.join(tmp_default, item)
    try:
        if os.path.isfile(s):
            shutil.copy2(s, d)
            print('Copied:', item)
        elif os.path.isdir(s):
            shutil.copytree(s, d)
            print('Copied dir:', item)
    except Exception as e:
        print('Skip', item, str(e)[:60])

options = Options()
options.add_argument('--user-data-dir=' + tmp)
options.add_argument('--profile-directory=Default')
options.add_argument('--headless=new')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')
options.add_argument('--disable-gpu')
options.add_argument('--window-size=1920,1080')
options.add_argument('--no-first-run')
options.add_argument('--disable-sync')

print('Starting Chrome with copied profile...')
service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service, options=options)

print('Navigating to Firestore console...')
driver.get('https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore')
time.sleep(12)
print('URL:', driver.current_url[:100])
print('Title:', driver.title)
driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_page.png')
print('Screenshot saved.')

if 'accounts.google.com' in driver.current_url:
    print('RESULT: Redirected to Google login - cookies not transferred from profile.')
    with open('page_src.html', 'w', encoding='utf-8', errors='replace') as f:
        f.write(driver.page_source)
    driver.quit()
    sys.exit(1)

print('SUCCESS: Logged in! Looking for Create database button...')
wait = WebDriverWait(driver, 25)

try:
    btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'Create database')]")))
    print('Found Create database button! Clicking...')
    btn.click()
    time.sleep(4)
    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_step1.png')
except Exception as e:
    print('Create database button not found:', str(e)[:100])
    body = driver.find_element(By.TAG_NAME, 'body').text
    print('Page text (first 500 chars):', body[:500])
    driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_error.png')
    driver.quit()
    sys.exit(1)

try:
    nxt = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(.,'Next')]")))
    nxt.click()
    time.sleep(3)
    print('Clicked Next')
except Exception as e:
    print('No Next button:', str(e)[:80])

try:
    tm = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'test mode')]")))
    tm.click()
    time.sleep(2)
    print('Selected test mode')
except Exception as e:
    print('No test mode option:', str(e)[:80])

try:
    en = wait.until(EC.element_to_be_clickable(
        (By.XPATH, "//button[contains(.,'Enable') or contains(.,'Create')]")
    ))
    en.click()
    print('Clicked Enable/Create - Firestore provisioning...')
    time.sleep(18)
except Exception as e:
    print('No Enable button:', str(e)[:80])

driver.save_screenshot(r'D:\BMS\bms\scratch_automate\fs_done.png')
print('Final screenshot saved.')
driver.quit()
print('DONE!')
