from PySide6.QtCore import QObject, Slot, Signal
from vault_manager import VaultManager

class WatchTowerBackend(QObject):
    # Σήματα για να ενημερώνουμε το UI 
    scanFinished = Signal(int, int, int) # weak, reused, breached
    isScanningChanged = Signal(bool)

    def __init__(self):
        super().__init__()
        self.manager = VaultManager()

    @Slot(str, str)
    def startScan(self, user_id, master_password):
        
        self.isScanningChanged.emit(True)
        
        try:
            # Τώρα έχουμε το password από το QML και το δίνουμε στον Manager!
            full_report = self.manager.scan_vault(user_id, master_password)
            
            # Αν γυρίσει success: False (π.χ. λάθος κωδικός)
            if not full_report.get("success", False):
                print(f"Error: {full_report.get('message')}")
                self.isScanningChanged.emit(False)
                return

            stats = full_report["stats"]
            self.scanFinished.emit(stats["weakCount"], stats["reusedCount"], stats["breachedCount"])

        except Exception as e:
            print(f"Error during scan: {e}")
            import traceback
            traceback.print_exc()
        finally:
            self.isScanningChanged.emit(False)