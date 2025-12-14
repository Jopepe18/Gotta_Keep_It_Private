import sys # not to be confuzed with syssy
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

#  import συνάρτησης από το άλλο
from login import LoginBackend 

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = LoginBackend()

    # σύνδεση με QML
    engine.rootContext().setContextProperty("backend", backend)

    current_dir = os.path.dirname(os.path.abspath(__file__))
    qml_file_path = os.path.join(current_dir, "../ui/Login.ui.qml")

    engine.load(qml_file_path)

    # Έλεγχος αν φόρτωσε σωστά
    if not engine.rootObjects():
        sys.exit(-1)

    sys.exit(app.exec())