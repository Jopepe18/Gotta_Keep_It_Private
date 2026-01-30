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
        # Περνάμε τη συνάρτηση update_progress στον manager
        result = self.manager.scan_vault(
            self.user_id, 
            self.password, 
            progress_callback=self.update_progress
        )
        self.finished.emit(result)

    def update_progress(self, val):
        self.progress.emit(val)


class WatchTowerBackend(QObject):
    # --- ΣΗΜΑΤΑ (SIGNALS) ---
    
    scanFinished = Signal(int, int, int, int,str,bool) # weak, reused, breached, total,network error
    
    chartStatsReady = Signal(int, int, int, int) # weak, reused, breached, safe
    
    # 3. ΓΙΑ ΤΑ ITEMS ΤΩΝ ΛΙΣΤΩΝ
    scanDataReady = Signal(list, list, list)
    
    # 4. ΓΙΑ ΤΟ UI LOADING
    isScanningChanged = Signal(bool)
    scanProgressUpdated = Signal(float)
    
    # 5. Signal to notify that passwords need refresh (security_status updated in DB)
    passwordsRefreshNeeded = Signal(str)  # user_id

    def __init__(self, manager):
        super().__init__()
        self.manager = manager
        self.worker = None
        self._current_user_id = ""

    @Slot(str, str)
    def startScan(self, user_id, master_password):
        self._current_user_id = user_id  
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
            chart_data = full_report.get("chartData", {}) # Τα δεδομένα για την πίτα

            # 1. Στέλνουμε δεδομένα για τις λίστες
            self.scanFinished.emit(
                stats["weakCount"], 
                stats["reusedCount"], 
                stats["breachedCount"], 
                stats["totalItems"],
                stats["score"],
                stats.get("networkError", False)
            )
            
            # 2. Στέλνουμε τα CHART stats (Για το Analytics Window)
            # Αν κάτι λείπει, στέλνουμε 0 
            self.chartStatsReady.emit(
                chart_data.get("weak", 0),
                chart_data.get("reused", 0),
                chart_data.get("breached", 0),
                chart_data.get("safe", 0)
            )
            
            # 3. Στέλνουμε τις λίστες
            self.scanDataReady.emit(
                full_report["weakItems"], 
                full_report["reusedItems"], 
                full_report["breachedItems"]
            )

        except Exception as e:
            print(f"Error handling results: {e}")
            import traceback
            traceback.print_exc() 
        finally:
            self.isScanningChanged.emit(False)
            self.scanProgressUpdated.emit(1.0) 
            
            # Emit signal to refresh passwords (security_status updated in DB)
            if self._current_user_id:
                self.passwordsRefreshNeeded.emit(self._current_user_id)
            
            # Καθαρίζουμε τον εργάτη
            self.worker = None