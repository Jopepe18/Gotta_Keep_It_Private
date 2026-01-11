from PySide6.QtCore import QObject, Slot, Signal
from watchtower_service import WatchtowerService

class WatchTowerBackend(QObject):
    # Σήματα για να ενημερώνουμε το UI 
    scanFinished = Signal(int, int, int) # weak, reused, breached
    isScanningChanged = Signal(bool)

    def __init__(self):
        super().__init__()
        self.service = WatchtowerService()

    @Slot(str)
    def startScan(self, user_id):
        # Ενημερώνουμε το UI ότι ξεκινάμε για να δείξει το loading
        self.isScanningChanged.emit(True)
        
        # Τρέχουμε τη σάρωση 
        stats = self.service.scan_vault(user_id)
        
        # Στέλνουμε τα αποτελέσματα
        self.scanFinished.emit(stats["weak"], stats["reused"], stats["breached"])
        self.isScanningChanged.emit(False)
