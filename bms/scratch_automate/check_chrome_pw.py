import sqlite3, os, shutil
src = r'C:\Users\kylej_z264ll1\AppData\Local\Google\Chrome\User Data\Default\Login Data'
tmp = 'tmp_login'
try:
    shutil.copy2(src, tmp)
    c = sqlite3.connect(tmp)
    cursor = c.cursor()
    cursor.execute("SELECT origin_url, username_value, substr(password_value, 1, 3) FROM logins WHERE origin_url LIKE '%google%'")
    for row in cursor.fetchall():
        print(row)
    c.close()
    os.remove(tmp)
except Exception as e:
    print(e)
