from PySide6.QtCore import QObject, Slot, Signal
from dtos import VaultCreationRequest
from vault_manager import VaultManager

class VaultBackend(QObject):
    vault_created = Signal(bool, str)
    operation_finished = Signal(bool, str) # Generic signal for updates
    userInfoReceived = Signal(str, str) # username, email
    vaultDeleted = Signal(bool, str) # success, message
    passwordVerified = Signal(bool,str) #signal if pass is correct
    vaultHandled = Signal(bool,str)  # success n msg  for export/import

    passwords_updated = Signal(list)
    cards_updated = Signal(list)
    card_decrypted = Signal(bool, dict, str)

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


    #---------------------Password Handling ----------------------

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
                "is_favorite": p.is_favorite,
                "has_totp": p.has_totp,
                "password": "••••••••",  # Placeholder - actual password decrypted on demand
                "note": p.note or "",
                "created_at": p.created_at.strftime("%Y-%m-%d %H:%M:%S") if p.created_at else "",
                "last_modified": p.last_modified.strftime("%Y-%m-%d %H:%M:%S") if p.last_modified else ""
            }
            for p in passwords
        ]
        print(f"VaultBackend: Emitting {len(passwords_list)} passwords")
        self.passwords_updated.emit(passwords_list)

    # Signal to return decrypted password details (with TOTP)
    password_decrypted = Signal(bool, str, str, str, bool)  # success, password, message, totp_code, has_totp
    
    @Slot(str, int)
    def decryptPassword(self, user_id, password_id):
        """Decrypt a single password entry for viewing"""
        print(f"VaultBackend: Decrypting password {password_id} for user {user_id}")
        result = self.manager.get_decrypted_password(user_id, password_id)
        if result["success"]:
            self.password_decrypted.emit(
                True, 
                result["password"], 
                "", 
                result.get("totp_code", ""),
                result.get("has_totp", False)
            )
        else:
            self.password_decrypted.emit(False, "", result["message"], "", False)

    @Slot(int, str)
    def deletePassword(self, password_id, user_id):
        print(f"VaultBackend: Deleting password {password_id} for user {user_id}")
        result = self.manager.delete_password(password_id)
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            # Refresh the list
            self.getPasswords(user_id)
        else:
            self.operation_finished.emit(False, result["message"])


    @Slot(str, str)
    def check_password_before_action(self, user_id, password):
        print(f"VaultBackend: Checking if password exists for {user_id}")
        result = self.manager.check_password(user_id, password)
        self.passwordVerified.emit(result["success"], result["message"])

    @Slot(str, str, str) # User ID, Password, File Path
    def export_vault(self, user_id, password, file_path):
        print(f"VaultBackend: Exporting vault for {user_id} to {file_path}")
        result = self.manager.export_vault(user_id, password, file_path)
        self.vaultHandled.emit(result["success"], result["message"])

    @Slot(str, str, str) # User ID, Password, File Path
    def import_vault(self, user_id, password, file_path):
        print(f"VaultBackend: Importing vault for {user_id} to {file_path}")
        result = self.manager.import_vault(user_id, password, file_path)
        self.vaultHandled.emit(result["success"], result["message"])



    @Slot(str, str, str, str, str, str, str, str)
    def addPassword(self, user_id, master_password, title, username, password, website, note, totp_secret):
        """Add a new password entry"""
        print(f"VaultBackend: Adding password for user {user_id}")
        entry_data = {
            "title": title,
            "username": username,
            "password": password,
            "website": website,
            "note": note,
            "totp_secret": totp_secret
        }
        result = self.manager.add_password(user_id, master_password, entry_data)
        
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            self.getPasswords(user_id) # Refresh list
        else:
            self.operation_finished.emit(False, result["message"])

    @Slot(str, int, str, str, str, str, str, str, str)
    def updatePassword(self, user_id, password_id, master_password, title, username, password, website, note, totp_secret):
        """Update an existing password entry"""
        print(f"VaultBackend: Updating password {password_id} for user {user_id}")
        entry_data = {
            "title": title,
            "username": username,
            "password": password,
            "website": website,
            "note": note,
            "totp_secret": totp_secret
        }
        result = self.manager.update_password(user_id, password_id, master_password, entry_data)
        
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            self.getPasswords(user_id) # Refresh list
        else:
            self.operation_finished.emit(False, result["message"])

    @Slot(str, int, bool)
    def setFavorite(self, user_id, password_id, is_favorite):
        print(
            f"VaultBackend: Setting favorite for password {password_id} "
            f"to {is_favorite}"
        )

        result = self.manager.set_favorite(user_id, password_id, is_favorite)

        if result["success"]:
           pass
        else:
            print("Failed to update favorite:", result.get("message"))

    @Slot(str, int, bool)
    def setFavoriteCard(self, user_id, card_id, is_favorite):
        result = self.manager.set_favorite_card(user_id, card_id, is_favorite)
        
        if result["success"]:
           pass
        else:
            print("Failed to update favorite:", result.get("message"))


    @Slot(str)
    def getCards(self, user_id):
        print(f"VaultBackend: Fetching cards for user {user_id}")
        cards = self.manager.get_cards(user_id)
        cards_list = [
            {
                "id": c.id,
                "title": c.title,
                "cardholder_name": c.cardholder_name,
                "is_favorite": c.is_favorite,
                "card_type": c.card_type,
                "card_number": "•••• •••• •••• ••••",  # Placeholder - actual password decrypted on demand
                "cvv": "•••",
                "expiration_date": c.expiration_date,
                "note": c.note or "",
                "created_at": c.created_at.strftime("%Y-%m-%d %H:%M:%S") if c.created_at else "",
                "last_modified": c.last_modified.strftime("%Y-%m-%d %H:%M:%S") if c.last_modified else ""
            }
            for c in cards
        ]
        print(f"VaultBackend: Emitting {len(cards_list)} cards")
        self.cards_updated.emit(cards_list)

    @Slot(str, int)
    def decryptCard(self, user_id, card_id):
        """Decrypt a single card entry for viewing"""
        print(f"VaultBackend: Decrypting card {card_id} for user {user_id}")
        result = self.manager.get_decrypted_card(user_id, card_id)
        if result["success"]:
            card_data = {
                "card_number": result["card_number"],
                "cvv": result["cvv"],
                "pin": result.get("pin", "")
            }
            self.card_decrypted.emit(True, card_data, "")
        else:
            self.card_decrypted.emit(False, {}, result["message"])
        
    @Slot(int, str)
    def deleteCard(self, card_id, user_id):
        """Delete a credit card entry"""
        print(f"VaultBackend: Deleting card {card_id} for user {user_id}")
        result = self.manager.delete_card(card_id)
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            # Refresh the list
            self.getCards(user_id)
        else:
            self.operation_finished.emit(False, result["message"])

    
    @Slot(str, str, str, str, str, str, str, str, str)
    def addCard(self, user_id, master_password, title, cardholder_name, card_number, cvv, card_type, expiration_date, note):
        """Add a new credit card entry"""
        print(f"VaultBackend: Adding card for user {user_id}")
        card_data = {
            "title": title,
            "cardholder_name": cardholder_name,
            "card_number": card_number,
            "cvv": cvv,
            "card_type": card_type,
            "expiration_date": expiration_date,
            "note": note
        }
        result = self.manager.add_card(user_id, master_password, card_data)
        
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            self.getCards(user_id)  # Refresh list
        else:
            self.operation_finished.emit(False, result["message"])

    @Slot(str)
    def addDebugCard(self, user_id):
        print(f"VaultBackend: Adding debug card for user {user_id}")
        success = self.manager.add_debug_card(user_id)
        if success:
            self.getCards(user_id)
        else:
            print("VaultBackend: Failed to add debug card")

    @Slot(str, int, str, str, str, str, str, str, str, str)
    def updateCard(self, user_id, card_id, master_password, title, cardholder_name, card_number, cvv, card_type, expiration_date, note):
        """Update an existing card entry"""
        print(f"VaultBackend: Updating card {card_id} for user {user_id}")
        card_data = {
            "title": title,
            "cardholder_name": cardholder_name,
            "card_number": card_number,
            "cvv": cvv,
            "card_type": card_type,
            "expiration_date": expiration_date,
            "note": note
        }
        result = self.manager.update_card(user_id, card_id, master_password, card_data)
        
        if result["success"]:
            self.operation_finished.emit(True, result["message"])
            self.getCards(user_id) # Refresh list
        else:
            self.operation_finished.emit(False, result["message"])

    @Slot(str, int, bool)
    def setCardFavorite(self, user_id, card_id, is_favorite):
        print(f"VaultBackend: Setting favorite for card {card_id} to {is_favorite}")
        result = self.manager.set_card_favorite(user_id, card_id, is_favorite)
        if result["success"]:
            pass
        else:
            print("Failed to update card favorite:", result.get("message"))
        
