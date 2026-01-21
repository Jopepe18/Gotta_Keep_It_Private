import sqlite3

DB_PATH = "app_data.db"

conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Get table structure
cursor.execute("PRAGMA table_info(credit_cards)")
columns = cursor.fetchall()

print("credit_cards table columns:")
for col in columns:
    print(f"  - {col[1]} ({col[2]})")

conn.close()