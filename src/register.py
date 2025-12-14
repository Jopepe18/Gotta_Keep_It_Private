from PySide6.QtCore import QObject, Slot, Signal

class RegisterBackend(QObject):
    register_status = Signal(bool, str)

    def __init__(self):
        super().__init__()

    @Slot(str, str, str)
    def attempt_register(self, username, password, confirm_password):
        print(f"Register attempt: Username={username}, Password={password}, Confirm={confirm_password}")
        print("parsing ok")
        self.register_status.emit(True, "Parsing OK")
