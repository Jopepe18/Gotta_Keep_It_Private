from PySide6.QtWidgets import QApplication, QWidget, QMainWindow

#from src import LoginPage


class MainWindow(QMainWindow):

    def __init__(self):    #Basic Consructor
        super().__init__()

        self.setWindowTitle('Password Manager')
        #set size

        #loginpage = LoginPage()

        #MENU
        menubar = self.menuBar()

        passMenu = menubar.addMenu("Passwords")
        ccMenu = menubar.addMenu("CreditCards")
        wtMenu = menubar.addMenu("WatchTower")
        gMenu = menubar.addMenu("Generator")
        sMenu = menubar.addMenu("Settings")

    
       passMenu.triggered.connect(lambda: print(f"Open PasswordScreen"))

        
        





app = QApplication()
window = MainWindow() 
window.show()

app.exec()
