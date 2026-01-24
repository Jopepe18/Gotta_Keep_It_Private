from PySide6.QtCore import QObject, Slot, Signal
from vault_manager import VaultManager
from PySide6.QtCore import QObject, Slot, Signal, QThread

class ScanWorker(QThread):
    progress = Signal(int)     
    finished = Signal(dict)    
    
    def __init__(self, manager, user_id, password):
        super().__init__()
        self.manager = manager
        self.user_id = user_id
        self.password = password

    def run(self):
        # Περνάμε τη συνάρτηση update_progress στον manage
        result = self.manager.scan_vault(
            self.user_id, 
            self.password, 
            progress_callback=self.update_progress
        )
        self.finished.emit(result)

    def update_progress(self, val):
        self.progress.emit(val)


class WatchTowerBackend(QObject):
    # Σήματα για να ενημερώνουμε το UI 
    scanFinished = Signal(int, int, int) # weak, reused, breached
    scanDataReady = Signal(list, list, list)
    isScanningChanged = Signal(bool)
    scanProgressUpdated = Signal(float)

    def __init__(self):
        super().__init__()
        self.manager = VaultManager()
        self.worker = None

    @Slot(str, str)
    def startScan(self, user_id, master_password):
        
        self.isScanningChanged.emit(True)
        self.scanProgressUpdated.emit(0.0)

        self.worker = ScanWorker(self.manager, user_id, master_password)
        self.worker.progress.connect(self.handle_progress)
        self.worker.finished.connect(self.handle_scan_complete)
        self.worker.start()
       
    def handle_progress(self, percent):
        # Μετατρέπουμε το 0-100 σε 0.0-1.0 για το QML
        self.scanProgressUpdated.emit(percent / 100.0)

    def handle_scan_complete(self, full_report):
        try:
            if not full_report.get("success", False):
                print(f"Error: {full_report.get('message')}")
                return

            stats = full_report["stats"]
            
            # Στέλνουμε τα νούμερα
            self.scanFinished.emit(stats["weakCount"], stats["reusedCount"], stats["breachedCount"])
            
            # Στέλνουμε τις λίστες
            self.scanDataReady.emit(
                full_report["weakItems"], 
                full_report["reusedItems"], 
                full_report["breachedItems"]
            )
        except Exception as e:
            print(f"Error handling results: {e}")
        finally:
            self.isScanningChanged.emit(False)
            self.scanProgressUpdated.emit(1.0) 
            
            # Καθαρίζουμε τον εργάτη
            self.worker = None