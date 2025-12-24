from PySide6.QtCore import QObject, Slot, Signal
from dtos import RegistrationRequest

class RegisterBackend(QObject):
    register_status = Signal(bool, str, str, str)  # success, message, secret_key, user_id

    def __init__(self, auth_manager):
        super().__init__()
        self.auth_manager = auth_manager

    @Slot(str, str, str, str)
    def attempt_register(self, username, email, password, confirm_password):
        print(f"Register attempt: Username={username}, Email={email}")
        
        req = RegistrationRequest(username=username, email=email, password=password, confirm_password=confirm_password)
        result = self.auth_manager.register_user(req)
        
        if result.success:
            print("Python: Registration Success")
            self.register_status.emit(True, result.msg, result.secret_key, result.user_id)
        else:
            print(f"Python: Registration Failed - {result.msg}")
            self.register_status.emit(False, result.msg, "", "")
