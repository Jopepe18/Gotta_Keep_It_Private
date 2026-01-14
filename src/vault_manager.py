from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO, ChangeEmailRequest, ChangeMasterPasswordRequest
from Key_Manager import KeyManager
from encryption_service import EncryptionService
import os

#σαν να είναι το Handle Credential μας, to be changed 
class VaultManager:
    """
    Manages logic for Vault creation and management.
    Interacts with Database.
    """
    def __init__(self):
        self.key_manager = KeyManager()
        self.encrypt_service = EncryptionService()

    def get_db(self):
        return SessionLocal()

    def create_new_vault(self, request: VaultCreationRequest) -> VaultCreationResult:
        print(f"VaultManager: Creating vault for User {request.user_id} with Name {request.vault_name}")

        if request.password != request.confirm_password:
             return VaultCreationResult(success=False, message="Vault passwords do not match")

        db: Session = self.get_db()
        try:
            # 1. Generate Salt (Τώρα ο KeyManager επιστρέφει bytes, οπότε είμαστε σωστοί)
            kdf_salt = self.key_manager.generate_Salt()
            
            # 2. Generate DEK (Data Encryption Key) - Το κλειδί που κρυπτογραφεί τα δεδομένα
            vault_dek = self.key_manager.generate_DEK()
            
            # 3. Derive KEK (Key Encryption Key) από το Password + Salt
            # Το derive_key του KeyManager περιμένει (str, bytes), που είναι ακριβώς αυτά που έχουμε τώρα.
            kek = self.key_manager.derive_key(request.password, kdf_salt)
            
            # 4. Encrypt the DEK (Key Wrapping)
            # Το encrypt_data επιστρέφει bytes, άρα το αποθηκεύουμε απευθείας.
            encrypted_vault_key = self.encrypt_service.encrypt_data(vault_dek, kek)

            # --- RECOVERY KEY INTEGRATION (UC-SK) ---
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            
            recovery_salt = None
            recovery_encrypted_key = None
            
            if user and user.secret_key:
                print(f"VaultManager: Encrypting Vault Key with Recovery Key for User {request.user_id}")
                # 4.1 Generate Recovery Salt
                recovery_salt = self.key_manager.generate_Salt()
                
                # 4.2 Derive Recovery KEK (Key Encryption Key) from Secret Key
                recovery_cek = self.key_manager.derive_key(user.secret_key, recovery_salt)
                
                # 4.3 Encrypt the DEK with the Recovery KEK
                recovery_encrypted_key = self.encrypt_service.encrypt_data(vault_dek, recovery_cek)
            else:
                print("VaultManager: WARNING - No secret_key found for user. Vault will NOT be recoverable via Forgot Password.")

            print(f"DEBUG: Salt type: {type(kdf_salt)}, Encrypted Key type: {type(encrypted_vault_key)}")

            # 5. Create Vault Entity
            new_vault = VaultModel(
                user_id=request.user_id,
                name=request.vault_name,
                kdf_salt=kdf_salt,                 # LargeBinary (bytes)
                encrypted_vault_key=encrypted_vault_key, # LargeBinary (bytes)
                recovery_salt=recovery_salt,       # LargeBinary (bytes)
                recovery_encrypted_key=recovery_encrypted_key # LargeBinary (bytes)
            )
            
            db.add(new_vault)
            db.commit()
            db.refresh(new_vault)

            print("VaultManager: Vault created successfully in DB")

            return VaultCreationResult(
                success=True, 
                message="Vault Created Successfully", 
                vault_id=new_vault.vault_id,
                recovery_key="pending-implementation"
            )

        except Exception as e:
            db.rollback() # Πολύ σημαντικό να κάνουμε rollback σε error
            print(f"VaultManager ERROR: {e}")
            import traceback
            traceback.print_exc() # Αυτό θα σου δείξει όλο το error στο τερματικό
            return VaultCreationResult(success=False, message=f"System Error: {str(e)}")
            
        finally:
            db.close()
            
    def add_debug_password(self, user_id: str) -> bool:
        db: Session = self.get_db()
        try:
            # Get Vault ID
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                print("VaultManager: No vault found for user")
                return False

            # Create Password Entry
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

    def get_passwords(self, user_id: str) -> list[PasswordDTO]:
        db: Session = self.get_db()
        try:
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            #βρίσκει και εμφανιζει το vault που έχει ως user id του vault, του συνδεδεμένου χρήστη
            if not vault:
                return []

            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()

            # Convert to DTOs
            return [
                PasswordDTO(
                    id=p.id,
                    title=p.title,
                    username=p.username,
                    website=p.website,
                    is_favorite=p.is_favorite,
                    encrypted_password=p.encrypted_password,
                    note=p.note,
                    created_at=p.created_at,
                    last_modified=p.last_modified
                ) for p in passwords
            ]
        finally:
            db.close()

    def change_email(self, request: 'ChangeEmailRequest') -> dict:
        """
        Changes the user's email address.
        
        """

        from encryption_service import EncryptionService
        encrypt_service = EncryptionService()

        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}

            # Verify password
            if not encrypt_service.verify_password(request.current_password, user.password_hash):
                return {"success": False, "message": "Invalid current password"}

            # Check if new email exists
            existing_email = db.query(UserModel).filter(UserModel.email == request.new_email).first()
            if existing_email:
                return {"success": False, "message": "Email already in use"}

            # Update Email
            user.email = request.new_email
            db.commit()
            return {"success": True, "message": "Email updated successfully"}
        except Exception as e:
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def change_master_password(self, request: 'ChangeMasterPasswordRequest') -> dict:
        """
        TODO
        προσοχή, εδώ αλλάζει το login password, όχι τον τρόπο αποκρυπτογράφησης των εγγραφών. 
        !!!να αλλαχθεί !! θα πρέπει να επανακρυπτογραφεί τις εγγραφές
        """
        from encryption_service import EncryptionService
        encrypt_service = EncryptionService()

        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}

            # Verify current password
            if not encrypt_service.verify_password(request.current_password, user.password_hash):
                return {"success": False, "message": "Invalid current password"}

            # RE-ENCRYPT ALL VAULT DATA
            # 1. Fetch Vault
            vault = db.query(VaultModel).filter(VaultModel.user_id == request.user_id).first()
            if not vault:
                
                 pass
            else:
                 # 2. Derive OLD KEK
                 # We need the salt used for the OLD password.
                 if not vault.kdf_salt or not vault.encrypted_vault_key:
                      return {"success": False, "message": "Vault is corrupted or missing encryption data."}

                 old_kek = self.key_manager.derive_key(request.current_password, vault.kdf_salt)
                 
                 # 3. Decrypt DEK (Unwrap)
                 try:
                    vault_dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, old_kek)
                 except Exception as e:
                     return {"success": False, "message": f"Failed to decrypt vault with current password: {e}"}

                 # 4. Generate NEW Salt and KEK
                 new_kdf_salt = self.key_manager.generate_Salt()
                 new_kek = self.key_manager.derive_key(request.new_password, new_kdf_salt)
                 
                 # 5. Re-Encrypt DEK (Wrap)
                 new_encrypted_vault_key = self.encrypt_service.encrypt_data(vault_dek, new_kek)
                 
                 # 6. Update Vault Records
                 vault.kdf_salt = new_kdf_salt
                 vault.encrypted_vault_key = new_encrypted_vault_key

            # Update to New Password Hash
            new_hash = encrypt_service.hash_password(request.new_password)
            user.password_hash = new_hash

            db.commit()
            return {"success": True, "message": "Password updated and Vault re-encrypted successfully"}
        except Exception as e:
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def get_user_info(self, user_id: str) -> dict:
        """
        Fetches username and email for user_id.
        """
        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}

            return {
                "success": True, 
                "username": user.username, 
                "email": user.email
            }
        except Exception as e:
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def delete_vault(self, user_id: str, password: str) -> dict:
        """
        Deletes the user account, vault, and all data.
        Verifies password first.
        """
        from encryption_service import EncryptionService
        encrypt_service = EncryptionService()
        
        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            # Verify password
            if not encrypt_service.verify_password(password, user.password_hash):
                return {"success": False, "message": "Invalid password"}
            
            # Delete User (Cascade should handle the rest)
            print(f"VaultManager: Deleting user {user_id} and all associated data.")
            db.delete(user)
            db.commit()
            return {"success": True, "message": "Vault deleted successfully"}
        except Exception as e:
            print(f"VaultManager: Error deleting account: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def delete_password(self, password_id: int) -> dict:
        """
        Deletes a password entry by its ID.
        """
        db: Session = self.get_db()
        try:
            password_entry = db.query(PasswordEntry).filter(PasswordEntry.id == password_id).first()
            if not password_entry:
                return {"success": False, "message": "Password entry not found"}
            
            db.delete(password_entry)
            db.commit()
            print(f"VaultManager: Password {password_id} deleted successfully")
            return {"success": True, "message": "Password deleted successfully"}
        except Exception as e:
            print(f"VaultManager: Error deleting password: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()
