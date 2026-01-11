from PySide6.QtCore import QObject, Slot, Signal
from dtos import VaultCreationRequest, ChangeEmailRequest, ChangeMasterPasswordRequest
from vault_manager import VaultManager

class VaultBackend(QObject):
    vault_created = Signal(bool, str)
    passwords_updated = Signal(list) 
    operation_finished = Signal(bool, str) # Generic signal for updates (Add/Edit/Delete/Settings)
    userInfoReceived = Signal(str, str) # username, email
    vaultDeleted = Signal(bool, str) # success, message

    def __init__(self, manager):
        super().__init__()
        self.manager = manager
    
    # --- ADD PASSWORD ---
    @Slot(str, str, str, str, str, str)
    def addPassword(self, user_id, title, username, password, website, note):
        print(f"Adding password for user {user_id}")
        success, msg = self.manager.add_password(user_id, title, username, password, website, note)
        self.operation_finished.emit(success, msg)
        if success: self.getPasswords(user_id) # Refresh list

    # --- EDIT PASSWORD ---
    @Slot(str, int, str, str, str, str, str)
    def editPassword(self, user_id, entry_id, title, username, password, website, note):
        print(f"Editing password ID {entry_id}")
        success = self.manager.edit_password(entry_id, title, username, password, website, note)
        if success:
            self.operation_finished.emit(True, "Password Updated")
            self.getPasswords(user_id) # Refresh list
        else:
            self.operation_finished.emit(False, "Update Failed")

    # --- DELETE PASSWORD ---
    @Slot(str, int)
    def deletePassword(self, user_id, entry_id):
        print(f"Deleting password ID {entry_id}")
        success = self.manager.delete_password(entry_id)
        if success:
            self.operation_finished.emit(True, "Password Deleted")
            self.getPasswords(user_id) # Refresh list
        else:
            self.operation_finished.emit(False, "Delete Failed")

    # --- SETTINGS: DELETE VAULT ---
    @Slot(str, str)
    def deleteVault(self, user_id, password):
        print(f"VaultBackend: Delete Vault Request for {user_id}")
        result = self.manager.delete_vault(user_id, password)
        self.vaultDeleted.emit(result["success"], result["message"])

    # --- SETTINGS: GET INFO ---
    @Slot(str)
    def getUserInfo(self, user_id):
        result = self.manager.get_user_info(user_id)
        if result["success"]:
            self.userInfoReceived.emit(result["username"], result["email"])
        else:
            print(f"Error fetching user info: {result.get('message')}")
    
    # --- SETTINGS: CHANGE EMAIL ---
    @Slot(str, str, str)
    def changeEmail(self, user_id, new_email, current_password):
        print("VaultBackend: Change Email Request")
        req = ChangeEmailRequest(user_id, new_email, current_password)
        result = self.manager.change_email(req)
        self.operation_finished.emit(result["success"], result["message"])

    # --- SETTINGS: CHANGE MASTER PASSWORD ---
    @Slot(str, str, str)
    def changeMasterPassword(self, user_id, current_password, new_password):
        print("VaultBackend: Change Password Request")
        req = ChangeMasterPasswordRequest(user_id, current_password, new_password)
        result = self.manager.change_master_password(req)
        self.operation_finished.emit(result["success"], result["message"])

    # --- VAULT CREATION ---
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

    # --- DEBUG ---
    @Slot(str)
    def addDebugPassword(self, user_id):
        print(f"VaultBackend: Adding debug password for user {user_id}")
        success = self.manager.add_debug_password(user_id)
        if success:
            self.getPasswords(user_id)
        else:
            print("VaultBackend: Failed to add debug password")

    # --- GET PASSWORDS ---
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
                "is_favorite": p.is_favorite,
                "password": p.password, # Προστέθηκε για να φαίνεται στο Edit
                "note": p.note # Προστέθηκε για να φαίνεται στο Edit
            }
            for p in passwords
        ]
        print(f"VaultBackend: Emitting {len(passwords_list)} passwords")
        self.passwords_updated.emit(passwords_list)
