import json 
from sqlalchemy.orm import Session
from database import SessionLocal
from Key_Manager import KeyManager
from encryption_service import EncryptionService
from models import VaultModel, PasswordEntry, UserModel
import os 
#currently not used, export vault implemented from vault_manager.py
#  sorry ιωαννα :)

class export_vault:

    def __init__(self):
        self.key_manager = KeyManager()
        self.encrypt_service = EncryptionService()

    def get_db(self):
        return SessionLocal()


    def export_vault(self, user_id: str, provided_password: str, file_path: str) -> dict:
        db: Session = self.get_db()
        try:
            # 1. Fetch the vault and its entries and the User
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            if not user:
                return {"success": False, "message": "User not found"}
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()
            if not vault:
                return {"success": False, "message": "Vault not found"}

            # 2. VERIFY: Check if the password is correct before proceeding
            if not self.encrypt_service.verify_password(provided_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password"}


            # 3. UNWRAP: Derive KEK to decrypt the Vault's DEK
            # Assuming your KeyManager has a derive_key function
            kek = self.key_manager.derive_key(provided_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)
            
            
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



    def import_vault_from_json(self, user_id: str, master_password: str, file_path: str) -> dict:
        """
        Reads a JSON file, encrypts the credentials, and saves them to the DB.
        """
        if not os.path.exists(file_path):
            return {"success": False, "message": "Import file not found."}

        db: Session = self.get_db()
        try:
            # 1. Fetch User and Vault
            user = db.query(UserModel).filter(UserModel.user_id == user_id).first()
            vault = db.query(VaultModel).filter(VaultModel.user_id == user_id).first()

            if not user or not vault:
                return {"success": False, "message": "User vault not initialized."}

            # 2. SECURITY: Verify Master Password before touching the vault
            if not self.encrypt_service.verify_password(master_password, user.password_hash):
                return {"success": False, "message": "Invalid Master Password."}

            # 3. KEYS: Derive KEK and Decrypt the Vault DEK
            # This DEK is what we will use to encrypt the new incoming passwords
            kek = self.key_manager.derive_key(master_password, vault.kdf_salt)
            dek = self.encrypt_service.decrypt_data(vault.encrypted_vault_key, kek)

            # 4. LOAD FILE: Parse the JSON data
            with open(file_path, 'r', encoding='utf-8') as f:
                imported_data = json.load(f)

            if not isinstance(imported_data, list):
                return {"success": False, "message": "Invalid JSON format. Expected a list of entries."}

            # 5. PROCESS: Encrypt and Save
            import_count = 0
            for entry in imported_data:
                # We take the plain text password from the JSON and encrypt it for the DB
                plain_password = entry.get("password", "")
                encrypted_password_blob = self.encrypt_service.encrypt_data(plain_password, dek)

                new_pass_entry = PasswordEntry(
                    vault_id=vault.vault_id,
                    title=entry.get("title", "Imported Entry"),
                    username=entry.get("username", ""),
                    website=entry.get("website", ""),
                    encrypted_password=encrypted_password_blob, # Stored as bytes (Nonce + Cipher)
                    note=entry.get("note", ""),
                    is_favorite=entry.get("is_favorite", False)
                )
                db.add(new_pass_entry)
                import_count += 1

            db.commit()
            return {"success": True, "message": f"Successfully imported {import_count} entries."}

        except json.JSONDecodeError:
            return {"success": False, "message": "The JSON file is corrupted or formatted incorrectly."}
        except Exception as e:
            db.rollback()
            return {"success": False, "message": f"Import Error: {str(e)}"}
        finally:
            db.close()