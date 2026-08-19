import sqlite3, shutil, os, json, base64, ctypes
from ctypes import wintypes

class DATA_BLOB(ctypes.Structure):
    _fields_ = [('cbData', wintypes.DWORD), ('pbData', ctypes.POINTER(ctypes.c_char))]

def dpapi_decrypt(data):
    blob_in = DATA_BLOB()
    blob_in.cbData = len(data)
    blob_in.pbData = ctypes.cast(ctypes.create_string_buffer(data), ctypes.POINTER(ctypes.c_char))
    blob_out = DATA_BLOB()
    if not ctypes.windll.crypt32.CryptUnprotectData(ctypes.byref(blob_in), None, None, None, None, 0, ctypes.byref(blob_out)):
        raise ctypes.WinError()
    result = ctypes.string_at(blob_out.pbData, blob_out.cbData)
    ctypes.windll.kernel32.LocalFree(blob_out.pbData)
    return result

# Get AES key
edge_path = r"C:\Users\kylej_z264ll1\AppData\Local\Microsoft\Edge\User Data"
with open(os.path.join(edge_path, "Local State"), 'r') as f:
    ls = json.load(f)
enc_key = base64.b64decode(ls['os_crypt']['encrypted_key'])[5:]
key = dpapi_decrypt(enc_key)
print(f"Key length: {len(key)}")

# Copy login data
tmp = r'D:\BMS\bms\scratch_automate\tmp_debug.db'
shutil.copy2(os.path.join(edge_path, "Default", "Login Data"), tmp)

conn = sqlite3.connect(tmp)
rows = conn.execute(
    "SELECT origin_url, username_value, password_value FROM logins WHERE origin_url LIKE '%google%' AND username_value != '' ORDER BY date_last_used DESC"
).fetchall()
conn.close()
os.remove(tmp)

from Crypto.Cipher import AES

print(f"\nFound {len(rows)} Google logins:")
for url, user, pwd in rows:
    print(f"\nURL: {url[:70]}")
    print(f"User: {user}")
    prefix = pwd[:4] if pwd else b''
    print(f"Prefix hex: {prefix.hex()}")
    print(f"Prefix text: {prefix}")
    try:
        iv = pwd[3:15]
        payload = pwd[15:]
        cipher = AES.new(key, AES.MODE_GCM, nonce=iv)
        dec = cipher.decrypt(payload)[:-16]
        print(f"Password: {dec.decode(errors='replace')}")
    except Exception as e:
        print(f"AES error: {e}")
