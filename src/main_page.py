from PySide6.QtWidgets import QApplication
from PySide6.QtCore import QFile
from PySide6.QtUiTools import QUiLoader



app = QApplication()

loader = QUiLoader()

file = QFile('gui.ui')  #fileeeee name
file.open(QFile.ReadOnly)

window = loader.load(file) 
file.close()

window.show()
app.exec()
