import sys 
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

from login import LoginBackend 
from register import RegisterBackend
from forgot_password import ForgotPasswordBackend
from auth_manager import AuthenticationManager
from menu import MenuBackend
from vault_backend import VaultBackend
from vault_manager import VaultManager
from watchtower_backend import WatchTowerBackend
from generator_backend import GeneratorBackend
from PasswordEvaluator import PasswordAnalyser

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Basic")
    engine = QQmlApplicationEngine()

    # 1. Initialize Shared Services
    auth_manager = AuthenticationManager()
    password_analyser = PasswordAnalyser() 
    
    # 2. Create Backends, injecting dependencies
    login_backend = LoginBackend(auth_manager)
    register_backend = RegisterBackend(auth_manager)
    forgot_password_backend = ForgotPasswordBackend(auth_manager)
    menu_backend = MenuBackend(auth_manager)
    vault_manager = VaultManager(password_analyser)
    vault_backend = VaultBackend(vault_manager)
    watchtower_backend = WatchTowerBackend(vault_manager)
    generator_backend = GeneratorBackend(password_analyser)
    
    # 3. Expose to QML
    engine.rootContext().setContextProperty("loginBackend", login_backend)
    engine.rootContext().setContextProperty("registerBackend", register_backend)
    engine.rootContext().setContextProperty("forgotPasswordBackend", forgot_password_backend)
    engine.rootContext().setContextProperty("menuBackend", menu_backend)
    engine.rootContext().setContextProperty("vaultBackend", vault_backend)
    engine.rootContext().setContextProperty("watchTowerBackend", watchtower_backend)
    engine.rootContext().setContextProperty("generatorBackend", generator_backend)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file_path = os.path.join(current_dir, "../ui/Main.qml")

    engine.load(qml_file_path)

    # Έλεγχος αν φόρτωσε σωστά
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())
