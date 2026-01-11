from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry, CreditCardEntry, UserModel
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO, ChangeEmailRequest, ChangeMasterPasswordRequest
from encryption_service import EncryptionService

class VaultManager:
    def __init__(self):
        self.encrypt_service = EncryptionService()

    def get_db(self):
        return SessionLocal()

    # --- VAULT CREATION ---
    def create_new_vault(self, request: VaultCreationRequest) -> VaultCreationResult:
        print(f"VaultManager: Creating vault for User {request.user_id} with Name {request.vault_name}")
        
        if request.password != request.confirm_password:
             return VaultCreationResult(success=False, message="Vault passwords do not match")

        db: Session = self.get_db()
        try:
            # Create Vault Entity
            new_vault = VaultModel(
                user_id=request.user_id,
                name=request.vault_name
            )
            db.add(new_vault)
            db.commit()
            db.refresh(new_vault)
            
            print("VaultManager: Vault created successfully in DB")
            return VaultCreationResult(
                success=True, 
                message="Vault Created Successfully", 
                vault_id=new_vault.vault_id,
                recovery_key="generated-recovery-key-placeholder"
            )
        except Exception as e:
            print(f"VaultManager: Error creating vault: {e}")
            return VaultCreationResult(success=False, message=str(e))
        finally:
            db.close()

    # --- DEBUGGING ---
    def add_debug_password(self, user_id: str) -> bool:
        db: Session = self.get_db()
        try:
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                print("VaultManager: No vault found for user")
                return False
            
            new_pass = PasswordEntry(
                vault_id=vault.vault_id,
                title="Debug Password Service",
                username="debug_user@example.com",
                website="www.debug-service.com",
                encrypted_password="encrypted_dummy_password", 
                note="This is a debug entry, remove before release"
            )
            db.add(new_pass)
            db.commit()
            print("VaultManager: Debug password added")
            return True
        except Exception as e:
            print(f"VaultManager: Error adding debug password: {e}")
            return False
        finally:
            db.close()

    # --- READ DATA (GET) ---
    # Χρησιμοποιείται από το VaultBackend για να γεμίσει τη λίστα στο UI
    def get_all_passwords(self, user_id: str) -> list:
        db: Session = self.get_db()
        try:
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return []
            
            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
            
            result = []
            dummy_key = b'0123456789abcdef0123456789abcdef' # Προσωρινό κλειδί
            
            for p in passwords:
                # Αποκρυπτογράφηση (αν είναι encrypted) ή εμφάνιση raw αν είναι debug
                try:
                    decrypted_pass = self.encrypt_service.decrypt_data(p.encrypted_password, dummy_key)
                except:
                    decrypted_pass = p.encrypted_password

                result.append({
                    "id": p.id,
                    "title": p.title,
                    "username": p.username,
                    "password": decrypted_pass,
                    "website": p.website,
                    "note": p.note,
                    "is_favorite": p.is_favorite
                })
            return result
        finally:
            db.close()

    # --- ADD PASSWORD ---
    def add_password(self, user_id: str, title: str, username: str, password: str, website: str, note: str):
        db = self.get_db()
        try:
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return False, "Vault not found"

            dummy_key = b'0123456789abcdef0123456789abcdef'
            enc_pass = self.encrypt_service.encrypt_data(password, dummy_key)

            new_entry = PasswordEntry(
                vault_id=vault.vault_id,
                title=title,
                username=username,
                encrypted_password=enc_pass,
                website=website,
                note=note,
                security_status="UNKNOWN"
            )
            db.add(new_entry)
            db.commit()
            return True, "Password Saved"
        except Exception as e:
            print(f"Error adding password: {e}")
            return False, str(e)
        finally:
            db.close()

    # --- EDIT PASSWORD ---
    def edit_password(self, entry_id: int, title: str, username: str, password: str, website: str, note: str) -> bool:
        db = self.get_db()
        try:
            entry = db.query(PasswordEntry).filter(PasswordEntry.id == entry_id).first()
            if not entry:
                return False
            
            entry.title = title
            entry.username = username
            entry.website = website
            entry.note = note
            
            dummy_key = b'0123456789abcdef0123456789abcdef'
            entry.encrypted_password = self.encrypt_service.encrypt_data(password, dummy_key)
            
            db.commit()
            return True
        except Exception as e:
            print(f"Error editing password: {e}")
            return False
        finally:
            db.close()

    # --- DELETE PASSWORD ---
    def delete_password(self, entry_id: int) -> bool:
        db = self.get_db()
        try:
            entry = db.query(PasswordEntry).filter(PasswordEntry.id == entry_id).first()
            if not entry:
                return False
            
            db.delete(entry)
            db.commit()
            return True
        except Exception as e:
            print(f"Error deleting password: {e}")
            return False
        finally:
            db.close()

    # --- DELETE CARD ---
    def delete_card(self, entry_id: int) -> bool:
        db = self.get_db()
        try:
            entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == entry_id).first()
            if not entry: return False
            db.delete(entry)
            db.commit()
            return True
        except Exception as e:
            print(f"Error deleting card: {e}")
            return False
        finally:
            db.close()

    # --- SETTINGS: CHANGE EMAIL ---
    def change_email(self, request: 'ChangeEmailRequest') -> dict:
        db: Session = self.get_db()
        try:
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            if not self.encrypt_service.verify_password(request.current_password, user.password_hash):
                return {"success": False, "message": "Invalid current password"}
            
            existing_email = db.query(UserModel).filter(UserModel.email == request.new_email).first()
            if existing_email:
                return {"success": False, "message": "Email already in use"}

            user.email = request.new_email
            db.commit()
            return {"success": True, "message": "Email updated successfully"}
        except Exception as e:
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    # --- SETTINGS: CHANGE MASTER PASSWORD ---
    def change_master_password(self, request: 'ChangeMasterPasswordRequest') -> dict:
        db: Session = self.get
