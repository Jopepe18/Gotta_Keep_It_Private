from typing import List, Any
from dtos import SecurityReport
from BreachAPI import BreachAPIService
from PasswordEvaluator import PasswordAnalyser 

class Watchtower:
    def __init__(self, existing_analyser=None):
        self.breach_checker = BreachAPIService()
        if existing_analyser:
            self.password_analyser = existing_analyser
        else:
            self.password_analyser = PasswordAnalyser()

    def analyze_vault(self, decrypted_credentials: List[Any], progress_callback=None) -> SecurityReport:
        report = SecurityReport()
        password_map = {}
        total_entropy = 0.0
        total_items = len(decrypted_credentials)

        # --- ΦΑΣΗ 1: ΑΝΑΛΥΣΗ ΚΑΙ MAPS (Προετοιμασία) ---
        for index, item in enumerate(decrypted_credentials):
            if progress_callback and total_items > 0:
                current_percent = int((index / total_items) * 90)
                progress_callback(10 + current_percent)

            pwd = item.password            
            
            # Έλεγχοι API & Strength
            b_count = self.breach_checker.get_breach_count(pwd)

            #Check if it failed (-1) or succeeded
            if b_count == -1:
             # Network Error Logic
                item.breach_count_val = 0 
                item.is_breached = False
                report.has_network_error = True # Set the flag!
            else:
                # Success Logic
                item.breach_count_val = b_count
                item.is_breached = (b_count > 0)
            strength_label = self.password_analyser.evaluate_strength(pwd)
            entropy = self.password_analyser.calculate_entropy(pwd)
            total_entropy += entropy

            # Ορίζουμε τα flags (Ανεξάρτητα μεταξύ τους)
            item.is_breached = (b_count > 0)
            item.is_weak = (strength_label == "Weak")
            item.is_reused = False # Θα το δούμε παρακάτω

            # Χτίζουμε το map για έλεγχο reused
            if pwd not in password_map:
                password_map[pwd] = []
            password_map[pwd].append(item)

        if progress_callback: progress_callback(100)

        # --- ΦΑΣΗ 2: ΕΛΕΓΧΟΣ REUSED ---
        for pwd, items_list in password_map.items():
            if len(items_list) > 1:
                for entry in items_list:
                    entry.is_reused = True
                    # Βρίσκουμε τα ονόματα των άλλων λογαριασμών
                    other_titles = [e.title for e in items_list if e.id != entry.id]
                    if not other_titles:
                         other_titles = [e.title for e in items_list if e is not entry]
                    entry.reused_on_list = ", ".join(other_titles)

        # --- ΦΑΣΗ 3: ΚΑΤΑΜΕΤΡΗΣΗ (ΤΟ ΔΙΠΛΟ ΣΥΣΤΗΜΑ) ---
        
        # A. Μετρητές Γραφήματος (Priority Logic - Waterfall)
        # Χρησιμοποιείται ΜΟΝΟ για να σχεδιαστεί σωστά η πίτα (100%)
        chart_breached = 0
        chart_reused = 0
        chart_weak = 0
        chart_safe = 0

        # B. Πραγματικοί Μετρητές (Overlap Logic)
        # Χρησιμοποιούνται για τις Λίστες και τα Labels (Action Required)
        real_breached = 0
        real_reused = 0
        real_weak = 0

        for item in decrypted_credentials:
            
            # --- 1. ΥΠΟΛΟΓΙΣΜΟΣ ΓΙΑ ΛΙΣΤΕΣ (ΟΛΗ Η ΑΛΗΘΕΙΑ) ---
            # Αν ένας κωδικός έχει και τα 3 προβλήματα, μπαίνει και στις 3 λίστες
            if item.is_breached:
                real_breached += 1
                report.breached_credentials.append(item)
            
            if item.is_weak:
                real_weak += 1
                report.weak_credentials.append(item)

            if item.is_reused:
                real_reused += 1
                report.reused_credentials.append(item)
            
            # ΥΠΟΛΟΓΙΣΜΟΣ ΓΙΑ ΓΡΑΦΗΜΑ (ΠΡΟΤΕΡΑΙΟΤΗΤΑ) ---
            # Εδώ χρησιμοποιούμε if/elif για να μετρήσει ΜΙΑ φορά
            if item.is_breached:
                chart_breached += 1
                item.security_status = "BREACHED"
            elif item.is_reused:
                chart_reused += 1
                item.security_status = "REUSED"
            elif item.is_weak:
                chart_weak += 1
                item.security_status = "WEAK"
            else:
                chart_safe += 1
                item.security_status = "SAFE"
        if total_items > 0:
            report.average_entropy = total_entropy / total_items
        
        # Αποθηκεύουμε τα REAL νούμερα στο report (για το main UI)
        report.weak_count = real_weak
        report.reused_count = real_reused
        report.breached_count = real_breached

        # Αποθηκεύουμε τα CHART νούμερα σε ειδικό dictionary
        report.chart_stats = {
            "weak": chart_weak,
            "reused": chart_reused,
            "breached": chart_breached,
            "safe": chart_safe
        }

        return report

    def format_json_response(self, report, total_items) -> dict:
        score_text = "Weak"
        if report.average_entropy > 60: score_text = "Excellent"
        elif report.average_entropy > 40: score_text = "Strong"
        elif report.average_entropy > 20: score_text = "Medium"
        else: score_text = "Weak"

        # Αν υπάρχει Breach -> CRITICAL
        if report.breached_count > 0:
            score_text = "Critical"
        elif report.weak_count + report.reused_count > 0:
            if score_text == "Excellent" or score_text == "Strong":
                score_text = "Needs Attention"

        if total_items == 0:
            score_text = "Empty"
        
        return {
            "success": True,
            "stats": {
                # Τα  νούμερα (με Overlap) για το WatchTowerPage UI "Action requiered"
                "weakCount": report.weak_count,
                "reusedCount": report.reused_count,
                "breachedCount": report.breached_count,
                "totalItems": total_items,
                "score": score_text ,
                "networkError": report.has_network_error
            },
            "chartData": {
                # νούμερα κανονικοποιημενά γιά το chart  για το Analytics Window
                "weak": report.chart_stats["weak"],
                "reused": report.chart_stats["reused"],
                "breached": report.chart_stats["breached"],
                "safe": report.chart_stats["safe"]
            },
            # Οι λίστες για json serialazation
            "weakItems": self._serialize_simple(report.weak_credentials),
            "reusedItems": self._serialize_reused(report.reused_credentials),
            "breachedItems": self._serialize_breached(report.breached_credentials)
        }

    # --- SERIALIZERS ---
    def _serialize_breached(self, entries):
        data = []
        for entry in entries:
            count = getattr(entry, 'breach_count_val', 0) 
            data.append({
                "id": entry.id, "title": entry.title, "username": entry.username,
                "breachCount": count, "status": "COMPROMISED",
                "description": f"Found in {count:,} data breaches!"
            })
        return data

    def _serialize_reused(self, entries):
        data = []
        for entry in entries:
            others = getattr(entry, 'reused_on_list', "")
            if not others: others = "other accounts"
            
            data.append({
                "id": entry.id, "title": entry.title, "username": entry.username,
                "status": "REUSED", "relatedAccounts": others,
                "description": f"Also used on: {others}"
            })
        return data
        
    def _serialize_simple(self, entries):
        data = []
        for entry in entries:
            data.append({
                "id": entry.id, "title": entry.title, "username": entry.username,
                "status": "WEAK", "description": "Password is too weak."
            })
        return data