from PySide6.QtCore import QObject, Slot, Signal

class LoginBackend(QObject):
    login_status = Signal(bool, str)

    def __init__(self):
        super().__init__()

    
    @Slot(str, str) # χάρη σε αυτό εδώ το βλέπει η QML
    def attempt_login(self, username, password):
        print(f"Python: Username={username}, Password={password}")

        if username == "admin" and password == "1234":
            print("Python: Επιτυχία")
            self.login_status.emit(True, "Επιτυχής σύνδεση!")
        else:
            print("Python: Αποτυχία")
            self.login_status.emit(False, "Λάθος στοιχεία.")