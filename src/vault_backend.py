from PySide6.QtCore import QObject, Slot, Signal
from dtos import VaultCreationRequest
from vault_manager import VaultManager

class VaultBackend(QObject):
    vault_created = Signal(bool, str) # success, message
    passwords_updated = Signal(list) 

    def __init__(self, manager):
        super().__init__()
        self.manager = manager

    @Slot(str, str, str, str)
    def create_vault(self, user_id, vault_name, password, confirm_password):
        print("VaultBackend: Received create_vault request")
        
        req = VaultCreationRequest(
            user_id=user_id,
            vault_name=vault_name,
            password=password,
            confirm_password=confirm_password
        )
        
        result = self.manager.create_new_vault(req)
        
        if result.success:
            print(f"VaultBackend: Success - {result.message}")
            self.vault_created.emit(True, result.message)
        else:
            print(f"VaultBackend: Failure - {result.message}")
            self.vault_created.emit(False, result.message)

    @Slot(str)
    def addDebugPassword(self, user_id):
        print(f"VaultBackend: Adding debug password for user {user_id}")
        success = self.manager.add_debug_password(user_id)
        if success:
            self.getPasswords(user_id)
        else:
            print("VaultBackend: Failed to add debug password")

    @Slot(str)
    def getPasswords(self, user_id):
        print(f"VaultBackend: Fetching passwords for user {user_id}")
        passwords = self.manager.get_passwords(user_id)
        passwords_list = [
            {
                "id": p.id,
                "title": p.title,
                "username": p.username,
                "website": p.website,
                "is_favorite": p.is_favorite
            }
            for p in passwords
        ]
        print(f"VaultBackend: Emitting {len(passwords_list)} passwords")
        self.passwords_updated.emit(passwords_list)
