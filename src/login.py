from PySide6.QtWidgets import QApplication, QWidget, QMainWindow, QLabel,QVBoxLayout, QPushButton, QHBoxLayout, QLineEdit
from PySide6.QtCore import Qt


class LoginPage():

    def __init__(self):    #Basic Consructor
        super().__init__()

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
        button.clicked.connect(self.login_funct) #lambda: print...login_funct()

        layout.addWidget(inner_container)

    def login_funct():
        print(f"Button Clicked" )
        window = MainInterface()












