from typing import List, Any
from dtos import SecurityReport
from BreachAPI import BreachAPIService
from PasswordEvaluator import PasswordAnalyser 

class Watchtower:
    def __init__(self):
        # Τα εργαλεία μας (Dependency Injection)
        self.breach_checker = BreachAPIService()
        self.password_analyser = PasswordAnalyser() 

    def analyze_vault(self, decrypted_credentials: List[Any]) -> SecurityReport:
        report = SecurityReport()
        password_map = {} # Map για τον έλεγχο Reused
        total_entropy = 0.0
        
        for item in decrypted_credentials:
            pwd = item.password            
            
            # --- 1. ΕΡΩΤΗΣΗ ΣΤΟ BREACH API ---
            # Ρωτάμε: "Πόσες φορές διέρρευσε;"
            b_count = self.breach_checker.get_breach_count(pwd)
            item.breach_count_val = b_count # Το αποθηκεύουμε για το UI

            # --- 2. ΕΡΩΤΗΣΗ ΣΤΟN ANALYSER ---
            # Ρωτάμε: "Πόσο δυνατός είναι;" (Weak/Medium/Strong/Excellent)
            strength_label = self.password_analyser.evaluate_strength(pwd)
            
            # Ζητάμε και το entropy ΜΟΝΟ για να βγάλουμε τον μέσο όρο του Vault στο τέλος
            # Ο Analyser κάνει τα μαθηματικά
            entropy = self.password_analyser.calculate_entropy(pwd)
            total_entropy += entropy

            # --- 3. ΑΠΟΦΑΣΗ (Business Logic) ---
            if b_count > 0:
                item.security_status = "COMPROMISED"
            elif strength_label == "Weak":
                item.security_status = "WEAK"
            else:
                # Medium, Strong, Excellent θεωρούνται "SAFE" για τη βάση δεδομένων
                item.security_status = "SAFE"

            # --- 4. ΠΡΟΕΤΟΙΜΑΣΙΑ ΓΙΑ REUSED ---
            if pwd not in password_map:
                password_map[pwd] = []
            password_map[pwd].append(item)

        # --- 5. ΕΛΕΓΧΟΣ REUSED (Δουλειά του Watchtower) ---
        # Εδώ συγκρίνουμε τους κωδικούς μεταξύ τους
        for pwd, items_list in password_map.items():
            if len(items_list) > 1:
                titles = [entry.title for entry in items_list]
                
                for entry in items_list:
                    # Αν είναι ήδη COMPROMISED, δεν του αλλάζουμε status (είναι πιο σοβαρό)
                    if entry.security_status != "COMPROMISED":
                         entry.security_status = "REUSED"
                    
                    # Φτιάχνουμε τη λίστα "Also used on..."
                    other_titles = [t for t in titles if t != entry.title]
                    entry.reused_on_list = ", ".join(other_titles)

        # --- 6. ΚΑΤΑΣΚΕΥΗ REPORT ---
        for item in decrypted_credentials:
            if item.security_status == "WEAK":
               report.weak_count += 1
               report.weak_credentials.append(item)
            elif item.security_status == "REUSED":
               report.reused_count += 1
               report.reused_credentials.append(item)
            elif item.security_status == "COMPROMISED":
               report.breached_count += 1
               report.breached_credentials.append(item)
        
        # Υπολογισμός μέσου όρου
        if len(decrypted_credentials) > 0:
            report.average_entropy = total_entropy / len(decrypted_credentials)

        return report
    def format_json_response(self, report, total_items) -> dict:
        """Πακετάρει τα αποτελέσματα σε JSON για το UI"""
        
        # Υπολογισμός Score Text
        score_text = "Weak"
        if report.average_entropy > 60: score_text = "Excellent"
        elif report.average_entropy > 40: score_text = "Strong"
        elif report.average_entropy > 20: score_text = "Medium"

        return {
            "success": True,
            "stats": {
                "weakCount": report.weak_count,
                "reusedCount": report.reused_count,
                "breachedCount": report.breached_count,
                "totalItems": total_items,
                "score": score_text
            },
            "weakItems": self._serialize_simple(report.weak_credentials),
            "reusedItems": self._serialize_reused(report.reused_credentials),
            "breachedItems": self._serialize_breached(report.breached_credentials)
        }

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