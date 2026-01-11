from models import VaultModel
import sys
class VaultRepository:
    def __init__(self, db_session):
        self.db = db_session

    def create_vault(self, user_id, name, salt, encrypted_key):
        # Force conversion to bytes
        try:
            salt = bytes(salt)
            encrypted_key = bytes(encrypted_key)
        except Exception as e:
            print(f"REPO ERROR conversion: {e}"); sys.stdout.flush()
            raise e
            
        print(f"REPO DEBUG: salt type: {type(salt)}, key type: {type(encrypted_key)}"); sys.stdout.flush()
        
        new_vault = VaultModel(
            user_id=user_id,
            name=name,
            kdf_salt=salt,               # <--- ΝΕΟ ΠΕΔΙΟ (Bytes)
            encrypted_vault_key=encrypted_key # <--- ΝΕΟ ΠΕΔΙΟ (Bytes)
        )
        self.db.add(new_vault)
        self.db.commit()
        self.db.refresh(new_vault)
        return new_vault