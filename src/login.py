from PySide6.QtWidgets import QApplication, QWidget, QMainWindow, QLabel,QVBoxLayout, QPushButton, QHBoxLayout, QLineEdit
from PySide6.QtCore import Qt


class MainWindow(QMainWindow):

    def __init__(self):    #Basic Consructor
        super().__init__()

        self.setWindowTitle('Password Manager')
        #set size

        container = QWidget()
        self.setCentralWidget(container)

        layout = QVBoxLayout(container)

        label1= QLabel('One') 
        layout.addWidget(label1)

        inner_container = QWidget()
        inner_layout = QHBoxLayout(inner_container)

        line_edit= QLineEdit()
        inner_layout.addWidget(line_edit)  

        button = QPushButton('Login')
        inner_layout.addWidget(button)
        button.clicked.connect(login_funct()) #lambda: print...

        layout.addWidget(inner_container)

    def login_funct():
        print(f"Button Clicked" )


# You need one (and only one) QApplication instance per application.
app = QApplication()
window = MainWindow() 
window.show()

app.exec()












