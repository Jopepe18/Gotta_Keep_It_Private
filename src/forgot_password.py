from PySide6.QtCore import QObject, Slot, Signal
from dtos import RecoveryVerificationRequest

class ForgotPasswordBackend(QObject):
    # Signal to emit status to QML
    # success: bool, message: str, userId: str, hasVault: bool
    verify_status = Signal(bool, str, str, bool)

    def __init__(self, auth_manager):
        super().__init__()
        self.auth_manager = auth_manager

    @Slot(str, str, str)
    def attempt_verify(self, username, email, secret_key):
        print(f"Verify attempt: Username={username}, Email={email}")
        
        req = RecoveryVerificationRequest(username=username, email=email, secret_key=secret_key)
        result = self.auth_manager.verify_recovery_info(req)
        
        if result.success:
            print("Python: Match")
            self.verify_status.emit(True, "Match", "", False)
        else:
            print("Python: No Match")
            self.verify_status.emit(False, "No Match", "", False)

    @Slot(str, str, str, str)
    def attempt_recovery_change(self, username, secret_key, new_pass, confirm_pass):
        print(f"Recovery Change attempt: User={username}")
        from dtos import RecoveryChangeRequest # local import 
        
        req = RecoveryChangeRequest(username=username, secret_key=secret_key, new_password=new_pass, confirm_password=confirm_pass)
        result = self.auth_manager.execute_password_recovery(req)
        
        # Check if result is a dict (success) or bool (failure)
        if isinstance(result, dict) and result.get("success"):
            print("Python: Recovery Change Success")
            self.verify_status.emit(True, "Password Changed Successfully", result["user_id"], result["has_vault"])
        else:
             print("Python: Recovery Change Failed")
             self.verify_status.emit(False, "Failed to change password", "", False)
