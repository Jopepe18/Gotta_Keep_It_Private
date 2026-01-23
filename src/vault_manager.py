import os
import sys
from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry, UserModel, CreditCardEntry
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO, ChangeEmailRequest, ChangeMasterPasswordRequest
from Key_Manager import KeyManager
from encryption_service import EncryptionService
from PasswordEvaluator import PasswordAnalyser 
import json
from watchtower_page import Watchtower

#σαν να είναι το Handle Credential μας, to be changed 
class VaultManager:
    """
    Manages logic for Vault creation and management.
    Interacts with Database.
    """
    def __init__(self):
        self.key_manager = KeyManager()
        self.encrypt_service = EncryptionService()
        self.PasswordHandler = PasswordAnalyser()

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
            import traceback
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
            import traceback
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

        db: Session = self.get_db()
        try:
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}

            # Verify password
            if not self.encrypt_service.verify_password(request.current_password, user.password_hash):
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
        

        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == request.user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}

            # Verify current password
            if not self.encrypt_service.verify_password(request.current_password, user.password_hash):
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
            new_hash = self.encrypt_service.hash_password(request.new_password)
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

        
        db: Session = self.get_db()
        try:
            from models import UserModel
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            # Verify password
            if not self.encrypt_service.verify_password(password, user.password_hash):
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
            

    #helper method for neeter code 
    def _prepare_vault_session(self, db, user_id, password):
        """Internal helper with full debugging for user, and encryption."""
    
        print(f"DEBUG: Starting operation for user {user_id}")
        print(f"DEBUG: Password received (length): {len(password)}")

        # 2. Fetch User & Vault
        user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
        if not user:
            print("DEBUG: User not found!")
            raise Exception("User not found")

        vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
        if not vault:
            print("DEBUG: Vault not found!")
            raise Exception("Vault not found")

        print(f"DEBUG: User found, vault_id={vault.vault_id}")
        print(f"DEBUG: kdf_salt type={type(vault.kdf_salt)}, length={len(vault.kdf_salt) if vault.kdf_salt else 'None'}")
        print(f"DEBUG: encrypted_vault_key type={type(vault.encrypted_vault_key)}, length={len(vault.encrypted_vault_key) if vault.encrypted_vault_key else 'None'}")

        # 3. VERIFY: Password Check
        if not self.encrypt_service.verify_password(password, user.password_hash):
            print("DEBUG: Password verification FAILED")
            raise Exception("Invalid Master Password")

        print("DEBUG: Password verification PASSED")

        # 4. VALIDATE: Encryption data check
        if not vault.kdf_salt or not vault.encrypted_vault_key:
            print("DEBUG: Vault encryption data missing")
            raise Exception("Vault encryption data is missing or corrupted.")

        # 5. UNWRAP: Derive KEK and decrypt DEK
        print(f"DEBUG: Deriving KEK from password and salt")
        kek = self.key_manager.derive_key(password, vault.kdf_salt)
        
        print(f"DEBUG: Attempting to decrypt vault key...")
        dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
        print(f"DEBUG: DEK decrypted successfully, length={len(dek)}")
        
        return vault, dek

    def clean_filepath(self, file_path: str):
        #for Path Verification & Cleaning
        if sys.platform == "win32":
            if file_path.startswith("/") or file_path.startswith("\\"):
                file_path = file_path.lstrip("/\\")
            file_path = os.path.normpath(file_path)

        print(f"DEBUG: Final path being used by Python: {file_path}")

        return file_path


    def export_vault(self, user_id: str, provided_password: str, file_path: str) -> dict:
        db = self.get_db()
        try:
            # Get everything from the helpers
            clean_path = self.clean_filepath(file_path)
            vault, dek = self._prepare_vault_session(db, user_id, provided_password)
            
            # DECRYPT PASSWORD ENTRIES
            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
            decrypted_passwords = []
            
            print(f"DEBUG: Found {len(passwords)} passwords to decrypt.")

            for p in passwords:
                plain_pass_bytes = self.encrypt_service.decrypt_data(p.encrypted_password, dek)
                decrypted_passwords.append({
                    "type": "password",
                    "title": p.title,
                    "username": p.username,
                    "website": p.website,
                    "password": plain_pass_bytes.decode('utf-8'),
                    "note": p.note,
                    "is_favorite": p.is_favorite
                })

            # DECRYPT CREDIT CARD ENTRIES
            cards = db.query(CreditCardEntry).filter(CreditCardEntry.vault_id == vault.vault_id).all()
            decrypted_cards = []
            
            print(f"DEBUG: Found {len(cards)} credit cards to decrypt.")

            for c in cards:
                plain_number_bytes = self.encrypt_service.decrypt_data(c.encrypted_number, dek)
                plain_cvv_bytes = self.encrypt_service.decrypt_data(c.encrypted_cvv, dek)
                decrypted_cards.append({
                    "type": "credit_card",
                    "title": c.title,
                    "cardholder_name": c.cardholder_name,
                    "card_number": plain_number_bytes.decode('utf-8'),
                    "cvv": plain_cvv_bytes.decode('utf-8'),
                    "card_type": c.card_type,
                    "expiration_date": c.expiration_date,
                    "note": c.note,
                    "is_favorite": c.is_favorite
                })

            # Create export data structure
            export_data = {
                "passwords": decrypted_passwords,
                "credit_cards": decrypted_cards
            }

            # Write to JSON file
            with open(clean_path, 'w', encoding='utf-8') as f:
                json.dump(export_data, f, indent=4)

            total_items = len(decrypted_passwords) + len(decrypted_cards)
            return {"success": True, "message": f"Exported {total_items} items ({len(decrypted_passwords)} passwords, {len(decrypted_cards)} cards) to {clean_path}"}
        
        except Exception as e:
            print(f"DEBUG: Export Exception: {str(e)}")
            return {"success": False, "message": f"Export failed: {str(e)}"}
        finally:
            db.close()


    def import_vault(self, user_id: str, provided_password: str, file_path: str) -> dict:
        db = self.get_db()
        try:
            # Get everything from the helpers
            clean_path = self.clean_filepath(file_path)
            vault, dek = self._prepare_vault_session(db, user_id, provided_password)

            if not os.path.exists(clean_path):
                return {"success": False, "message": f"File not found: {clean_path}"}

            # READ JSON
            with open(clean_path, 'r', encoding='utf-8') as f:
                imported_data = json.load(f)

            passwords_imported = 0
            cards_imported = 0

            # Check if new structured format or old flat format
            if isinstance(imported_data, dict) and "passwords" in imported_data:
                # New structured format
                passwords_list = imported_data.get("passwords", [])
                cards_list = imported_data.get("credit_cards", [])
            else:
                # Old flat format (backwards compatibility)
                passwords_list = imported_data if isinstance(imported_data, list) else []
                cards_list = []

            print(f"DEBUG: Importing {len(passwords_list)} passwords and {len(cards_list)} cards from JSON.")

            # Import passwords
            for item in passwords_list:
                encrypted_pass = self.encrypt_service.encrypt_data(item["password"].encode('utf-8'), dek)
                
                new_entry = PasswordEntry(
                    vault_id=vault.vault_id,
                    title=item.get("title", "Imported Entry"),
                    username=item.get("username", ""),
                    website=item.get("website", ""),
                    encrypted_password=encrypted_pass,
                    note=item.get("note", ""),
                    is_favorite=item.get("is_favorite", False)
                )
                db.add(new_entry)
                passwords_imported += 1

            # Import credit cards
            for item in cards_list:
                encrypted_number = self.encrypt_service.encrypt_data(item["card_number"].encode('utf-8'), dek)
                encrypted_cvv = self.encrypt_service.encrypt_data(item["cvv"].encode('utf-8'), dek)
                
                new_card = CreditCardEntry(
                    vault_id=vault.vault_id,
                    title=item.get("title", "Imported Card"),
                    cardholder_name=item.get("cardholder_name", ""),
                    encrypted_number=encrypted_number,
                    encrypted_cvv=encrypted_cvv,
                    card_type=item.get("card_type", "Other"),
                    expiration_date=item.get("expiration_date", ""),
                    note=item.get("note", ""),
                    is_favorite=item.get("is_favorite", False)
                )
                db.add(new_card)
                cards_imported += 1

            db.commit()
            print("DEBUG: Import committed successfully.")
            total = passwords_imported + cards_imported
            return {"success": True, "message": f"Imported {total} items ({passwords_imported} passwords, {cards_imported} cards) successfully."}

        except Exception as e:
            db.rollback()
            print(f"DEBUG: Import Exception: {str(e)}")
            return {"success": False, "message": f"Import failed: {str(e)}"}
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

    def set_favorite_card(self, user_id: str, card_id: int, is_favorite: bool):
            db: Session = self.get_db()
            try:
                card_entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == card_id).first()

                if not card_entry:
                    return {"success": False, "message": "Card entry not found"}
                
                card_entry.is_favorite = is_favorite
                db.commit()

                print(f"VaultManager: Card {card_id} favorite status set to {is_favorite}")
                return {"success": True, "message": "Favorite status updated"}
                
            except Exception as e:
                db.rollback()
                print(f"VaultManager: Failed to update favorite: {e}")
                return {"success": False, "message": str(e)}
            finally:
                db.close()


    def scan_vault(self, user_id: str, master_password: str) -> dict:
        print("VaultManager: Starting Watchtower scan...")
        db = self.get_db()
        
        # Αρχικοποίηση (ή το έχεις στο __init__)
        analyzer = Watchtower() 

        try:
            # 1. AUTH & DECRYPT (Μένει ίδιο)
            try:
                vault, dek = self._prepare_vault_session(db, user_id, master_password)
            except Exception as e:
                return {"success": False, "message": str(e)}

            # 2. FETCH (Μένει ίδιο)
            passwords = db.query(PasswordEntry).filter(PasswordEntry.vault_id == vault.vault_id).all()
            decrypted_objects = []

            # 3. DECRYPT LOOP (Μένει ίδιο)
            for entry in passwords:
                try:
                    plain_pass_bytes = self.encrypt_service.decrypt_data(entry.encrypted_password, dek)
                    entry.password = plain_pass_bytes.decode('utf-8')
                    decrypted_objects.append(entry)
                except Exception:
                    continue

            # 4. ANALYZE (Μένει ίδιο)
            # Ο Analyzer κάνει τη δουλειά και γεμίζει τα status
            report = analyzer.analyze_vault(decrypted_objects)

            # 5. COMMIT (Σώζουμε τα WEAK/REUSED στη βάση)
            db.commit()
            
            # --- Η ΜΕΓΑΛΗ ΑΛΛΑΓΗ ΕΔΩ ---
            # 6. FORMATTING: Ζητάμε το έτοιμο JSON από τον Analyzer!
            # Δεν έχουμε πια serialize methods εδώ μέσα.
            response_data = analyzer.format_json_response(report, len(decrypted_objects))
            
            # 7. CLEANUP (Μένει ίδιο)
            for entry in decrypted_objects:
                if hasattr(entry, 'password'): del entry.password

            print("Watchtower: Scan complete.")
            return response_data

        except Exception as e:
            print(f"Watchtower Error: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()


    def add_debug_card(self, user_id: str) -> bool:
        """
        Adds a debug card entry. 
        NOTE: This creates an entry with a properly encrypted card.
        We use the recovery key to decrypt the DEK since we don't have the user's card here.
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
            
            # Encrypt the debug card Number and cvv properly
            debug_plain_cardNumber = "1234 5678 1234 5678"
            encrypted_cardNumber = self.encrypt_service.encrypt_data(debug_plain_cardNumber, vault_dek)
            debug_plain_cardCvv = "830"
            encrypted_cvv = self.encrypt_service.encrypt_data(debug_plain_cardCvv, vault_dek)

            # Create Password Entry with PROPERLY ENCRYPTED password
            new_card = CreditCardEntry(
                vault_id = vault.vault_id,
                title = "Debug Card",
                cardholder_name = "Name",
                card_type = "Mastercard",
                expiration_date = "8/2028",
                encrypted_number = encrypted_cardNumber,  # Now properly encrypted!
                encrypted_cvv = encrypted_cvv,
                note="This is a debug entry, remove before release",
            )
            db.add(new_card)
            db.commit()
            print("VaultManager: Debug card added (encrypted)")
            return True
        except Exception as e:
            print(f"VaultManager: Error adding debug card: {e}")
            import traceback
            traceback.print_exc()
            return False
        finally:
            db.close()

    def get_cards(self, user_id: str) -> list:
        db: Session = self.get_db()
        try:
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return []

            cards = db.query(CreditCardEntry).filter(CreditCardEntry.vault_id == vault.vault_id).all()
            return cards
        finally:
            db.close()

    def get_decrypted_card(self, user_id: str, card_id: int) -> dict:
    
        db: Session = self.get_db()
        try:
            # Get user, vault, and card entry
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user or not user.secret_key:
                return {"success": False, "message": "User not found or missing secret key"}
            
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}
            
            card_entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == card_id).first()
            if not card_entry:
                return {"success": False, "message": "Card entry not found"}
            
            # Decrypt DEK using recovery key
            if not vault.recovery_salt or not vault.recovery_encrypted_key:
                return {"success": False, "message": "Vault recovery data missing"}
            
            recovery_kek = self.key_manager.derive_key(user.secret_key, vault.recovery_salt)
            vault_dek = self.encrypt_service.decrypt_data(vault.recovery_encrypted_key, recovery_kek)
            
            # Decrypt the card details
            decrypted_number = self.encrypt_service.decrypt_data(card_entry.encrypted_number, vault_dek)
            decrypted_cvv = self.encrypt_service.decrypt_data(card_entry.encrypted_cvv, vault_dek)
            
            return {
                "success": True,
                "card_number": decrypted_number.decode('utf-8'),
                "cvv": decrypted_cvv.decode('utf-8')
            }
        except Exception as e:
            print(f"VaultManager: Error decrypting card: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def delete_card(self, card_id: int) -> dict:
        """
        Deletes a credit card entry by its ID.
        """
        db: Session = self.get_db()
        try:
            card_entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == card_id).first()
            if not card_entry:
                return {"success": False, "message": "Card entry not found"}
            
            db.delete(card_entry)
            db.commit()
            print(f"VaultManager: Card {card_id} deleted successfully")
            return {"success": True, "message": "Card deleted successfully"}
        except Exception as e:
            print(f"VaultManager: Error deleting card: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def add_card(self, user_id: str, master_password: str, card_data: dict) -> dict:
        """
        Adds a new credit card entry to the vault.
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

            # 2. Verify Master Password
            if not self.encrypt_service.verify_password(master_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}

            # 3. Derive KEK and Decrypt DEK
            if not vault.kdf_salt or not vault.encrypted_vault_key:
                return {"success": False, "message": "Vault encryption data missing"}
            
            kek = self.key_manager.derive_key(master_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            
            if not dek:
                return {"success": False, "message": "Failed to decrypt vault key"}

            # 4. Encrypt the card details
            encrypted_number = self.encrypt_service.encrypt_data(card_data.get('card_number', ''), dek)
            encrypted_cvv = self.encrypt_service.encrypt_data(card_data.get('cvv', ''), dek)

            # 5. Create Entry
            new_entry = CreditCardEntry(
                vault_id=vault.vault_id,
                title=card_data.get('title', 'Untitled Card'),
                cardholder_name=card_data.get('cardholder_name', ''),
                card_type=card_data.get('card_type', ''),
                expiration_date=card_data.get('expiration_date', ''),
                encrypted_number=encrypted_number,
                encrypted_cvv=encrypted_cvv,
                note=card_data.get('note', '')
            )
            
            db.add(new_entry)
            db.commit()
            return {"success": True, "message": "Card added successfully"}

        except Exception as e:
            print(f"VaultManager: Error adding card: {e}")
            import traceback
            traceback.print_exc()
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def update_card(self, user_id: str, card_id: int, master_password: str, card_data: dict) -> dict:
        """
        Updates an existing credit card entry.
        """
        db: Session = self.get_db()
        try:
            # 1. Fetch User, Vault, and Card Entry
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}
            
            card_entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == card_id).first()
            if not card_entry:
                return {"success": False, "message": "Card entry not found"}

            # 2. Verify Master Password
            if not self.encrypt_service.verify_password(master_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}

            # 3. Derive KEK and Decrypt DEK
            if not vault.kdf_salt or not vault.encrypted_vault_key:
                return {"success": False, "message": "Vault encryption data missing"}
            
            kek = self.key_manager.derive_key(master_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            
            if not dek:
                return {"success": False, "message": "Failed to decrypt vault key"}

            # 4. Encrypt the card details
            encrypted_number = self.encrypt_service.encrypt_data(card_data.get('card_number', ''), dek)
            encrypted_cvv = self.encrypt_service.encrypt_data(card_data.get('cvv', ''), dek)

            # 5. Update Entry
            card_entry.title = card_data.get('title', 'Untitled Card')
            card_entry.cardholder_name = card_data.get('cardholder_name', '')
            card_entry.card_type = card_data.get('card_type', '')
            card_entry.expiration_date = card_data.get('expiration_date', '')
            card_entry.encrypted_number = encrypted_number
            card_entry.encrypted_cvv = encrypted_cvv
            card_entry.note = card_data.get('note', '')
            
            from datetime import datetime
            card_entry.last_modified = datetime.utcnow()
            
            db.commit()
            return {"success": True, "message": "Card updated successfully"}

        except Exception as e:
            print(f"VaultManager: Error updating card: {e}")
            import traceback
            traceback.print_exc()
            return {"success": False, "message": str(e)}
        finally:
            db.close()

    def set_card_favorite(self, user_id: str, card_id: int, is_favorite: bool):
        """Set favorite status for a card entry"""
        db: Session = self.get_db()
        try:
            card_entry = db.query(CreditCardEntry).filter(CreditCardEntry.id == card_id).first()

            if not card_entry:
                return {"success": False, "message": "Card entry not found"}
            
            card_entry.is_favorite = is_favorite
            db.commit()

            print(f"VaultManager: Card {card_id} favorite status set to {is_favorite}")
            return {"success": True, "message": "Favorite status updated"}
            
        except Exception as e:
            db.rollback()
            print(f"VaultManager: Failed to update card favorite: {e}")
            return {"success": False, "message": str(e)}
        finally:
            db.close()
