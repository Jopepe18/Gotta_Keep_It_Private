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

    def scan_vault(self, user_id: str):
        print("Watchtower: Starting scan...")
        db = self.get_db()        
        try:
            # Βρες το vault του χρήστη
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault: return {"weak": 0, "reused": 0, "breached": 0}

            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
                      
            decrypted_objects = [] 

        
            for entry in passwords:
                try:
                    # Αποκρυπτογράφηση
                    plain_pass = self.encrypt_service.decrypt_data(entry.encrypted_password, self.temp_key)
                    
                    entry.password = plain_pass 
                    
                    decrypted_objects.append(entry)
                    
                except Exception as dec_error:
                    print(f"Decryption failed for one entry: {dec_error}")
                    continue

            report = self.reportcreation.analyze_vault(decrypted_objects)
            
            db.commit()
            print("Database updated with new security statuses.")

            for entry in decrypted_objects:
                if hasattr(entry, 'password'):
                    del entry.password

            return {
              "weak": self._serialize_list(report.weak_credentials),
              "reused": self._serialize_list(report.reused_credentials),
              "breached": self._serialize_list(report.breached_credentials),
              "counts": {
                 "weak": report.weak_count,
                 "reused": report.reused_count,
                 "breached": report.breached_count
              }
            }

        except Exception as e:
            print(f"Watchtower error: {e}")
            db.rollback() # Αν σκάσει, ακύρωσε τυχόν μισές αλλαγές
            return {"weak": 0, "reused": 0, "breached": 0}
            
        finally:
            db.close()

    def _serialize_list(self, entries):
        data = []
        for entry in entries:
            data.append({
                "id": entry.id,
                "title": entry.title,
                "username": entry.username,
                "status": entry.security_status,
                "website": getattr(entry, "website", "")
            })
        return data