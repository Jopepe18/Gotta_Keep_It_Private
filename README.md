# 🔐 Gotta Keep It Private (GKIP)

A secure, offline-first password manager built with Python and Qt/QML.

## ✨ Features!

- **Secure Vault Storage** - AES-256 encrypted password vault
- **Password Generator** - Generate strong, customizable passwords
- **WatchTower** - Check if your passwords have been compromised in data breaches
- **TOTP Support** - Two-factor authentication code generator
- **Credit Card Storage** - Securely store payment card information
- **Offline-First** - All data stored locally, no cloud dependency

## 📋 Requirements

- Python 3.10 or higher
- pip (Python package manager)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Jopepe18/Gotta_Keep_It_Private.git
cd Gotta_Keep_It_Private
```

### 2. Create Virtual Environment (Recommended)

```bash
python3 -m venv venv
source venv/bin/activate  # On macOS/Linux
# Or on Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Run the Application

```bash
python3 src/main.py
```


## 🔒 Security

- Master password never stored, used to derive encryption keys
- AES-256-GCM encryption for all sensitive data
- Argon2 key derivation function
- Local SQLite database - no network transmission of credentials

## 🛠️ Troubleshooting

**Application won't start?**
- Ensure Python 3.10+ is installed: `python3 --version`
- Verify all dependencies: `pip install -r requirements.txt`

**Qt/QML errors?**
- Make sure PySide6 is properly installed
- On macOS, you may need to allow the app in Security settings



---

*Σχεδιασμένο με αγάπη από ανθρώπους ❤️*
