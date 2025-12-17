import sys 
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from login import LoginBackend 
from register import RegisterBackend
from forgot_password import ForgotPasswordBackend
from auth_manager import AuthenticationManager

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Basic")
    engine = QQmlApplicationEngine()

    # 1. Initialize Authentication Manager
    auth_manager = AuthenticationManager()
    
    # 2. Create Backends, injecting the manager
    login_backend = LoginBackend(auth_manager)
    register_backend = RegisterBackend(auth_manager)
    forgot_password_backend = ForgotPasswordBackend(auth_manager)

    # 3. Expose to QML
    engine.rootContext().setContextProperty("loginBackend", login_backend)
    engine.rootContext().setContextProperty("registerBackend", register_backend)
    engine.rootContext().setContextProperty("forgotPasswordBackend", forgot_password_backend)


    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file_path = os.path.join(current_dir, "../ui/Main.qml")


    engine.load(qml_file_path)

    # Έλεγχος αν φόρτωσε σωστά
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())