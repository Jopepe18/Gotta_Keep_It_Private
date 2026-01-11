from PySide6.QtCore import QObject, Slot, Signal
from dtos import VaultCreationRequest
from vault_manager import VaultManager

class VaultBackend(QObject):
vault_created = Signal(bool, str)
passwords_updated = Signal(list)
operation_finished = Signal(bool, str) # Generic signal for updates
userInfoReceived = Signal(str, str) # username, email
vaultDeleted = Signal(bool, str) # success, message

def __init__(self, manager):
    super().__init__()
    self.manager = manager

@Slot(str, str)
def deleteVault(self, user_id, password):
    print(f"VaultBackend: Delete Vault Request for {user_id}")
    result = self.manager.delete_vault(user_id, password)
    self.vaultDeleted.emit(result["success"], result["message"])

@Slot(str)
def getUserInfo(self, user_id):
    result = self.manager.get_user_info(user_id)
    if result["success"]:
        self.userInfoReceived.emit(result["username"], result["email"])
    else:
        print(f"Error fetching user info: {result.get('message')}")

@Slot(str, str, str)
def changeEmail(self, user_id, new_email, current_password):
    print("VaultBackend: Change Email Request")
    from dtos import ChangeEmailRequest
    req = ChangeEmailRequest(user_id, new_email, current_password)
    result = self.manager.change_email(req)
    self.operation_finished.emit(result["success"], result["message"])

@Slot(str, str, str)
def changeMasterPassword(self, user_id, current_password, new_password):
    print("VaultBackend: Change Password Request")
    from dtos import ChangeMasterPasswordRequest
    req = ChangeMasterPasswordRequest(user_id, current_password, new_password)
    result = self.manager.change_master_password(req)
    self.operation_finished.emit(result["success"], result["message"])

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
    
@Slot
#def toggleFavorite(self, user_id, password_id):
#print(f"Vault Backend: Toggle favoirte for password {password_id}")
#result = self.manager.toggle_favorite(password_id)
#if result["success"]:
#self.getPasswords(user_id)
#else: 
#print(f"VaultBackend: Failed to toggle favoirte - {result.get('message')}")
