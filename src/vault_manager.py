from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO, ChangeEmailRequest, ChangeMasterPasswordRequest
#σαν να είναι το Handle Credential μας, to be changed 
class VaultManager:
    """
    Manages logic for Vault creation and management.
    Interacts with Database.
    """
    def __init__(self):
        pass

    def get_db(self):
        return SessionLocal()

    def create_new_vault(self, request: VaultCreationRequest) -> VaultCreationResult:
        print(f"VaultManager: Creating vault for User {request.user_id} with Name {request.vault_name}")
        
        if request.password != request.confirm_password:
             return VaultCreationResult(success=False, message="Vault passwords do not match")

        db: Session = self.get_db()
        try:
            # Create Vault Entity!
            new_vault = VaultModel(
                user_id=request.user_id, #!!!εδώ γινεται η διασύνδεση vault με user id
                name=request.vault_name
            )
            db.add(new_vault)
            db.commit()
            db.refresh(new_vault)
            
            print("VaultManager: Vault created successfully in DB")
            # Return Result
            
            return VaultCreationResult(
                success=True, 
                message="Vault Created Successfully", 
                vault_id=new_vault.vault_id,
                recovery_key="generated-recovery-key-placeholder"  #not used yet, επειδή μάλλον θα υλοποιήσουμε recovery στο state του user, και όχι στο vault
            )
        except Exception as e:
            print(f"VaultManager: Error creating vault: {e}")
            return VaultCreationResult(success=False, message=str(e))
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
                    is_favorite=p.is_favorite
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
            
            # Update to New Password
            new_hash = encrypt_service.hash_password(request.new_password)
            user.password_hash = new_hash
            
            # TODO: RE-ENCRYPT ALL VAULT DATA HERE
        
            
            db.commit()
            return {"success": True, "message": "Password updated successfully (Re-encryption pending)"}
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
