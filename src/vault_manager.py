from sqlalchemy.orm import Session
from database import SessionLocal
from models import VaultModel, PasswordEntry
from dtos import VaultCreationRequest, VaultCreationResult, PasswordDTO

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
