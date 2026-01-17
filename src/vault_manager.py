import os
import sys
from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry, UserModel
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO, ChangeEmailRequest, ChangeMasterPasswordRequest
from Key_Manager import KeyManager
from encryption_service import EncryptionService

import json

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
        print(f"VaultManager DEBUG: Password received (length): {len(request.password)}")

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
        """
        Adds a debug password entry. 
        NOTE: This creates an entry with a properly encrypted password.
        We use the recovery key to decrypt the DEK since we don't have the user's password here.
        """
        db: Session = self.get_db()
        try:
            # Get Vault and User
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                print("VaultManager: No vault found for user")
                return False
            
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user or not user.secret_key:
                print("VaultManager: No user or secret key found")
                return False
            
            # Decrypt the DEK using the recovery key
            if not vault.recovery_salt or not vault.recovery_encrypted_key:
                print("VaultManager: No recovery data - cannot encrypt debug password")
                return False
            
            recovery_kek = self.key_manager.derive_key(user.secret_key, vault.recovery_salt)
            vault_dek = self.encrypt_service.decrypt_data(vault.recovery_encrypted_key, recovery_kek)
            
            # Encrypt the debug password properly
            debug_plain_password = "DebugPassword123!"
            encrypted_password = self.encrypt_service.encrypt_data(debug_plain_password, vault_dek)

            # Create Password Entry with PROPERLY ENCRYPTED password
            new_pass = PasswordEntry(
                vault_id=vault.vault_id,
                title="Debug Password Service",
                username="debug_user@example.com",
                website="www.debug-service.com",
                encrypted_password=encrypted_password,  # Now properly encrypted!
                note="This is a debug entry, remove before release"
            )
            db.add(new_pass)
            db.commit()
            print("VaultManager: Debug password added (encrypted)")
            return True
        except Exception as e:
            print(f"VaultManager: Error adding debug password: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            db.close()

    def add_password(self, user_id: str, master_password: str, entry_data: dict) -> dict:
        """
        Adds a new password entry to the vault.
        """
        db: Session = self.get_db()
        try:
            # 1. Fetch User and Vault
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}

            # 2. Verify Master Password (and derive KEK same time)
            if not self.encrypt_service.verify_password(master_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}

            # 3. Derive KEK and Decrypt DEK
            if not vault.kdf_salt or not vault.encrypted_vault_key:
                return {"success": False, "message": "Vault encryption data missing"}
            
            kek = self.key_manager.derive_key(master_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            
            if not dek:
                return {"success": False, "message": "Failed to decrypt vault key"}

            # 4. Encrypt the new password
            encrypted_password = self.encrypt_service.encrypt_data(entry_data.get('password', ''), dek)

            # 5. Create Entry
            new_entry = PasswordEntry(
                vault_id=vault.vault_id,
                title=entry_data.get('title', 'Untitled'),
                username=entry_data.get('username', ''),
                website=entry_data.get('website', ''),
                encrypted_password=encrypted_password,
                note=entry_data.get('note', '')
            )
            
            db.add(new_entry)
            db.commit()
            return {"success": True, "message": "Password added successfully"}

        except Exception as e:
            print(f"VaultManager: Error adding password: {e}")
            traceback.print_exc()
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def update_password(self, user_id: str, password_id: int, master_password: str, entry_data: dict) -> dict:
        """
        Updates an existing password entry.
        """
        db: Session = self.get_db()
        try:
            # 1. Fetch User, Vault, and Password Entry
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}
            
            password_entry = db.query(PasswordEntry).filter(PasswordEntry.id == password_id).first()
            if not password_entry:
                return {"success": False, "message": "Password entry not found"}

            # 2. Verify Master Password (and derive KEK same time)
            if not self.encrypt_service.verify_password(master_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}

            # 3. Derive KEK and Decrypt DEK
            if not vault.kdf_salt or not vault.encrypted_vault_key:
                return {"success": False, "message": "Vault encryption data missing"}
            
            kek = self.key_manager.derive_key(master_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            
            if not dek:
                return {"success": False, "message": "Failed to decrypt vault key"}

            # 4. Encrypt the password (it might have changed)
            encrypted_password = self.encrypt_service.encrypt_data(entry_data.get('password', ''), dek)

            # 5. Update Entry
            password_entry.title = entry_data.get('title', 'Untitled')
            password_entry.username = entry_data.get('username', '')
            password_entry.website = entry_data.get('website', '')
            password_entry.encrypted_password = encrypted_password
            password_entry.note = entry_data.get('note', '')
            
            # Update last_modified implicitly via onupdate in model or explicitly here if needed.
            # Usually SQLAlchemy handles onupdate=func.now(), but explicit is safer if not set.
            from datetime import datetime
            password_entry.last_modified = datetime.utcnow()
            
            db.commit()
            return {"success": True, "message": "Password updated successfully"}

        except Exception as e:
            print(f"VaultManager: Error updating password: {e}")
            traceback.print_exc()
            return {"success": False, "message": str(e)}
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

    def get_decrypted_password(self, user_id: str, password_id: int) -> dict:
        """
        Decrypts a single password entry using the recovery key.
        Used when user wants to view the actual password.
        """
        db: Session = self.get_db()
        try:
            # Get user, vault, and password entry
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user or not user.secret_key:
                return {"success": False, "message": "User not found or missing secret key"}
            
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}
            
            password_entry = db.query(PasswordEntry).filter(PasswordEntry.id == password_id).first()
            if not password_entry:
                return {"success": False, "message": "Password entry not found"}
            
            # Decrypt DEK using recovery key
            if not vault.recovery_salt or not vault.recovery_encrypted_key:
                return {"success": False, "message": "Vault recovery data missing"}
            
            recovery_kek = self.key_manager.derive_key(user.secret_key, vault.recovery_salt)
            vault_dek = self.encrypt_service.decrypt_data(vault.recovery_encrypted_key, recovery_kek)
            
            # Decrypt the password
            decrypted_password = self.encrypt_service.decrypt_data(password_entry.encrypted_password, vault_dek)
            
            return {
                "success": True,
                "password": decrypted_password.decode('utf-8')
            }
        except Exception as e:
            print(f"VaultManager: Error decrypting password: {e}")
            return {"success": False, "message": str(e)}
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

    #verify password promt 
    def check_password(self, user_id, provided_password):
        db = self.get_db()
        try:
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            # Use your encryption service
            if self.encrypt_service.verify_password(provided_password, user.password_hash):
                return {"success": True, "message": "Verified"}
            else:
                return {"success": False, "message": "Invalid Master Password"}
        finally:
            db.close()
            
    def export_vault(self, user_id: str, provided_password: str, file_path: str) -> dict:
        #Verify file path 
        # Ensure the path is actually valid for the OS
        if sys.platform == "win32":
            # If it somehow still has a leading slash, strip it
            if file_path.startswith("/") or file_path.startswith("\\"):
                file_path = file_path.lstrip("/\\")
            
            # Convert forward slashes to backslashes if needed (Python handles both, but this is safer)
            file_path = os.path.normpath(file_path)

        print(f"DEBUG: Final path being used by Python: {file_path}")
  
        db: Session = self.get_db()
        try:
            print(f"EXPORT DEBUG: Starting export for user {user_id}")
            print(f"EXPORT DEBUG: Password received (length): {len(provided_password)}")
            
            # 1. Fetch the vault and its entries and the User
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}

            print(f"EXPORT DEBUG: User found, vault_id={vault.vault_id}")
            print(f"EXPORT DEBUG: kdf_salt type={type(vault.kdf_salt)}, length={len(vault.kdf_salt) if vault.kdf_salt else 'None'}")
            print(f"EXPORT DEBUG: encrypted_vault_key type={type(vault.encrypted_vault_key)}, length={len(vault.encrypted_vault_key) if vault.encrypted_vault_key else 'None'}")

            # 2. VERIFY: Check if the password is correct before proceeding
            if not self.encrypt_service.verify_password(provided_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}

            print("EXPORT DEBUG: Password verification PASSED")

            # 2.5. VALIDATE: Check vault has required encryption data
            if not vault.kdf_salt or not vault.encrypted_vault_key:
                return {"success": False, "message": "Vault encryption data is missing or corrupted. Please delete and recreate your vault."}

            # 3. UNWRAP: Derive KEK to decrypt the Vault's DEK
            print(f"EXPORT DEBUG: Deriving KEK from password (length {len(provided_password)}) and salt")
            kek = self.key_manager.derive_key(provided_password, vault.kdf_salt)
            print(f"EXPORT DEBUG: KEK derived, length={len(kek)}")
            
            print(f"EXPORT DEBUG: Attempting to decrypt vault key...")
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            print(f"EXPORT DEBUG: DEK decrypted successfully, length={len(dek)}")
            
            
            # 4. DECRYPT ENTRIES: Get all passwords and decrypt them
            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
            decrypted_list = []

            
            for p in passwords:
                plain_pass_bytes = self.encrypt_service.decrypt_data(p.encrypted_password, dek)
                decrypted_list.append({
                    "title": p.title,
                    "username": p.username,
                    "website": p.website,
                    "password": plain_pass_bytes.decode('utf-8'), # Convert bytes to string
                    "note": p.note
                })

            # 4. Write to JSON file
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(decrypted_list, f, indent=4)

            return {"success": True, "message": f"Exported {len(decrypted_list)} items to {file_path}"}
        
        except Exception as e:
            return {"success": False, "message": f"Export failed: {str(e)}"}
        finally:
            db.close()

    def set_favorite(self, user_id: str, password_id: int, is_favorite: bool):
            db: Session = self.get_db()
            try:
                password_entry = db.query(PasswordEntry).filter(PasswordEntry.id == password_id).first()

                if not password_entry:
                    return {"success": False, "message": "Password entry not found"}
                
                password_entry.is_favorite = is_favorite
                db.commit()

                print(f"VaultManager: Password {password_id} favorite status set to {is_favorite}")
                return {"success": True, "message": "Favorite status updated"}
                
            except Exception as e:
                db.rollback()
                print(f"VaultManager: Failed to update favorite: {e}")
                return {"success": False, "message": str(e)}
            finally:
                db.close()

