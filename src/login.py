from PySide6.QtCore import QObject, Slot, Signal
from dtos import LoginRequest

class LoginBackend(QObject):
    login_status = Signal(bool, str, str)  # success, message, secret_key

    def __init__(self, auth_manager):
        super().__init__()
        self.auth_manager = auth_manager

    @Slot(str, str) # χάρη σε αυτό εδώ    @Slot(str, str)
    def attempt_login(self, username, password):
        print(f"Python: Login attempt for Username={username}")
        
        req = LoginRequest(username=username, password=password)
        result = self.auth_manager.login(req)

        if result.success:
            print("Python: Επιτυχία")
            # We could store result.token here if needed
            self.login_status.emit(True, result.message, result.secret_key)
        else:
            print("Python: Αποτυχία")
            self.login_status.emit(False, result.message, "")