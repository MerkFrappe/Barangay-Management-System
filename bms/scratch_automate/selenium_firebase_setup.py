import subprocess
import time
import sys
import shutil
import os

def test_headless_chrome():
    """Test if headless Chrome works with a fresh temp profile"""
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from selenium.webdriver.chrome.options import Options
    from webdriver_manager.chrome import ChromeDriverManager

    options = Options()
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--remote-debugging-port=0")

    print("Testing headless Chrome with fresh temp profile...")
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    driver.get("https://www.google.com")
    print(f"✓ Chrome headless works! Title: {driver.title}")
    driver.quit()
    return True

def setup_driver_with_copied_profile():
    """Copy the Chrome profile to a temp dir and use it with Selenium"""
    from selenium import webdriver
    from selenium.webdriver.chrome.service import Service
    from selenium.webdriver.chrome.options import Options
    from webdriver_manager.chrome import ChromeDriverManager

    src_profile = r"C:\Users\kylej_z264ll1\AppData\Local\Google\Chrome\User Data\Default"
    temp_dir = r"D:\BMS\bms\scratch_automate\chrome_temp_profile"
    temp_default = os.path.join(temp_dir, "Default")

    # Copy profile if it doesn't exist or is outdated
    if os.path.exists(temp_dir):
        shutil.rmtree(temp_dir, ignore_errors=True)
    
    os.makedirs(temp_dir, exist_ok=True)
    print(f"Copying Chrome profile to {temp_dir}...")
    print("(This may take a moment...)")
    
    # Only copy the essential files for login session
    essential_items = [
        "Cookies", "Network", "Login Data", "Web Data",
        "Local State", "Preferences", "Secure Preferences"
    ]
    
    os.makedirs(temp_default, exist_ok=True)
    for item in essential_items:
        src = os.path.join(src_profile, item)
        dst = os.path.join(temp_default, item)
        try:
            if os.path.isfile(src):
                shutil.copy2(src, dst)
                print(f"  ✓ Copied {item}")
            elif os.path.isdir(src):
                shutil.copytree(src, dst)
                print(f"  ✓ Copied {item}/")
        except Exception as e:
            print(f"  ✗ Could not copy {item}: {e}")

    options = Options()
    options.add_argument(f"--user-data-dir={temp_dir}")
    options.add_argument("--profile-directory=Default")
    options.add_argument("--headless=new")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1920,1080")
    options.add_argument("--no-first-run")
    options.add_argument("--disable-sync")
    options.add_argument("--remote-debugging-port=0")
    options.add_experimental_option("excludeSwitches", ["enable-automation"])

    print("\nStarting Chrome with copied profile...")
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    return driver

def create_firestore(driver):
    from selenium.webdriver.common.by import By
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC

    print("\n--- Navigating to Firestore ---")
    driver.get("https://console.firebase.google.com/u/0/project/bms-system-2499a/firestore")
    time.sleep(10)
    
    print(f"URL: {driver.current_url}")
    print(f"Title: {driver.title}")
    
    # Take a screenshot for debugging
    driver.save_screenshot(r"D:\BMS\bms\scratch_automate\firestore_page.png")
    print("Screenshot saved to firestore_page.png")
    
    if 'accounts.google.com' in driver.current_url:
        print("⚠ Redirected to login - profile cookies didn't transfer.")
        # Save page source for debugging
        with open('page_source.html', 'w', encoding='utf-8') as f:
            f.write(driver.page_source)
        return False

    wait = WebDriverWait(driver, 20)
    
    try:
        create_btn = wait.until(EC.element_to_be_clickable(
            (By.XPATH, "//*[contains(text(),'Create database')]")
        ))
        print("✓ Found 'Create database'! Clicking...")
        create_btn.click()
        time.sleep(4)
        driver.save_screenshot(r"D:\BMS\bms\scratch_automate\after_create_click.png")

        # Next
        try:
            next_btn = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(.,'Next')]")))
            next_btn.click(); time.sleep(3)
        except: pass

        # Test mode
        try:
            test = wait.until(EC.element_to_be_clickable((By.XPATH, "//*[contains(text(),'test mode')]")))
            test.click(); time.sleep(2)
        except: pass

        # Enable
        try:
            enable = wait.until(EC.element_to_be_clickable((By.XPATH, "//button[contains(.,'Enable') or contains(.,'Create')]")))
            enable.click()
            print("✓ Firestore creation initiated!")
            time.sleep(15)
        except: pass

        driver.save_screenshot(r"D:\BMS\bms\scratch_automate\firestore_done.png")
        return True
    except Exception as e:
        print(f"Error: {e}")
        print("Page text:", driver.find_element(By.TAG_NAME, 'body').text[:500])
        return False

def main():
    # Step 1: Test plain headless Chrome
    try:
        test_headless_chrome()
    except Exception as e:
        print(f"Plain headless Chrome failed: {e}")
        sys.exit(1)
    
    # Step 2: Use copied profile
    try:
        driver = setup_driver_with_copied_profile()
    except Exception as e:
        print(f"Failed to start with copied profile: {e}")
        sys.exit(1)
    
    try:
        result = create_firestore(driver)
        print(f"\nFirestore setup: {'SUCCESS' if result else 'NEEDS LOGIN'}")
    finally:
        driver.quit()

if __name__ == "__main__":
    main()
