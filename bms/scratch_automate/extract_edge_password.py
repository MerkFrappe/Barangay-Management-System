import os, json, base64, sqlite3, shutil, sys
import win32crypt
from Crypto.Cipher import AES

def get_edge_password_for_google():
    edge_path = r"C:\Users\kylej_z264ll1\AppData\Local\Microsoft\Edge\User Data"
    
    local_state_path = os.path.join(edge_path, "Local State")
    with open(local_state_path, 'r', encoding='utf-8') as f:
        local_state = json.load(f)
    
    encrypted_key = base64.b64decode(local_state['os_crypt']['encrypted_key'])
    encrypted_key = encrypted_key[5:]
    key = win32crypt.CryptUnprotectData(encrypted_key, None, None, None, 0)[1]
    
    login_data = os.path.join(edge_path, "Default", "Login Data")
    tmp_login = os.path.join(os.path.dirname(__file__), "tmp_login_data")
    shutil.copy2(login_data, tmp_login)
    
    conn = sqlite3.connect(tmp_login)
    cursor = conn.cursor()
    cursor.execute("""
        SELECT origin_url, username_value, password_value 
        FROM logins 
        WHERE origin_url LIKE '%google%' AND username_value = 'kylejoshua878@gmail.com'
        ORDER BY date_last_used DESC
    """)
    rows = cursor.fetchall()
    conn.close()
    if os.path.exists(tmp_login):
        os.remove(tmp_login)
    
    for url, username, enc_pwd in rows:
        print(f"URL: {url}, User: {username}, Prefix: {enc_pwd[:10]}")
        try:
            if enc_pwd.startswith(b'v10') or enc_pwd.startswith(b'v11'):
                iv = enc_pwd[3:15]
                payload = enc_pwd[15:-16]
                tag = enc_pwd[-16:]
                cipher = AES.new(key, AES.MODE_GCM, nonce=iv)
                decrypted = cipher.decrypt_and_verify(payload, tag).decode('utf-8')
                print(f"Password: {decrypted}")
            else:
                decrypted = win32crypt.CryptUnprotectData(enc_pwd, None, None, None, 0)[1].decode('utf-8')
                print(f"Password: {decrypted}")
        except Exception as e:
            print(f"Error decrypting {url} for {username}: {e}")
    
if __name__ == "__main__":
    get_edge_password_for_google()
