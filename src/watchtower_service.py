import hashlib
import requests # Pip install requests
from collections import Counter
from sqlalchemy.orm import Session
from database import SessionLocal
from models import PasswordEntry, VaultModel
from encryption_service import EncryptionService

class WatchtowerService:
    def __init__(self):
        self.encrypt_service = EncryptionService()
        # Ένα dummy key για την αποκρυπτογράφηση (στην τελική έκδοση αλλάζουμε)
        self.temp_key = b'0123456789abcdef0123456789abcdef' 

    def get_db(self):
        return SessionLocal()

    # 1. Έλεγχος δύναμης
    def check_strength(self, password: str) -> str:
        """Επιστρέφει 'WEAK' ή 'SAFE'"""
        score = 0
        if len(password) >= 8: score += 1
        if len(password) >= 12: score += 1
        if any(c.isupper() for c in password): score += 1
        if any(c.isdigit() for c in password): score += 1
        if any(not c.isalnum() for c in password): score += 1
        
        return "SAFE" if score >= 4 else "WEAK"

    # 2. Έλεγχος διαρροών 
    def check_pwned(self, password: str) -> bool:
        """Ελέγχει αν ο κωδικός έχει διαρρεύσει χωρίς να τον στείλει ολόκληρο."""
        sha1_password = hashlib.sha1(password.encode('utf-8')).hexdigest().upper()
        prefix, suffix = sha1_password[:5], sha1_password[5:]
        
        try:
            url = f"https://api.pwnedpasswords.com/range/{prefix}"
            response = requests.get(url, timeout=2)
            if response.status_code != 200:
                return False
            
            # Ελέγχουμε αν το suffix υπάρχει στην απάντηση
            hashes = (line.split(':') for line in response.text.splitlines())
            for h, count in hashes:
                if h == suffix:
                    return True # Βρέθηκε σε διαρροή
            return False
        except:
            return False 

    # 3. Κύρια λειτουργία σάρωσης
    def scan_vault(self, user_id: str):
        print("Watchtower: Starting scan...")
        db = self.get_db()
        try:
            # Βρες το vault του χρήστη
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault: return {"weak": 0, "reused": 0, "breached": 0}

            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
            
            # Λίστα με αποκρυπτογραφημένους κωδικούς για έλεγχο reuse
            plain_passwords = []
            entries_map = {} 

            stats = {"weak": 0, "reused": 0, "breached": 0}

            # Αποκρυπτογράφηση και έλεγχοι ανά κωδικό
            for entry in passwords:
                plain_pass = self.encrypt_service.decrypt_data(entry.encrypted_password, self.temp_key)
                plain_passwords.append(plain_pass)
                
                if plain_pass not in entries_map:
                    entries_map[plain_pass] = []
                entries_map[plain_pass].append(entry)

                # Έλεγχος strength
                strength = self.check_strength(plain_pass)
                
                # Έλεγχος breach
                is_pwned = self.check_pwned(plain_pass)

                # Ενημέρωση status στη βάση
                if is_pwned:
                    entry.security_status = "COMPROMISED"
                    stats["breached"] += 1
                elif strength == "WEAK":
                    entry.security_status = "WEAK"
                    stats["weak"] += 1
                else:
                    entry.security_status = "SAFE"

            # Έλεγχος reuse 
            counts = Counter(plain_passwords)
            for pwd, count in counts.items():
                if count > 1:
                    stats["reused"] += count
                    # Μαρκάρουμε τους reused ως weak αν ήταν safe
                    for entry in entries_map[pwd]:
                        if entry.security_status == "SAFE":
                            entry.security_status = "WEAK" 

            db.commit()

            print(f"Watchtower: Scan complete. Weak: {stats['weak']}, Reused: {stats['reused']}, Breached: {stats['breached']}")
            
            return stats

        except Exception as e:
            print(f"Watchtower error: {e}")
            return {"weak": 0, "reused": 0, "breached": 0}
        finally:
            db.close()
