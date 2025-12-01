from PySide6.QtWidgets import QApplication, QWidget, QMainWindow, QLabel,QVBoxLayout
from PySide6.QtCore import Qt


class MainWindow(QMainWindow):

    def __init__(self):    #Basic Consructor
        super().__init__()

        self.setWindowTitle('Password Manager')

        container = QWidget()
        self.setCentralWidget(container)

        layout = QVBoxLayout(container)

        label1= QLabel('One') 
        layout.addWidget(label1)


# You need one (and only one) QApplication instance per application.
app = QApplication()
window = MainWindow() 
window.show()

app.exec()












