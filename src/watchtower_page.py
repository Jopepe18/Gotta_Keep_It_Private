from typing import List, Any
from dtos import SecurityReport
from BreachAPI import BreachAPIService
from PasswordEvaluator import PasswordAnalyser 

class Watchtower:
    def __init__(self):
        self.breach_checker = BreachAPIService()
        self.password_analyser = PasswordAnalyser() 

    def analyze_vault(self, decrypted_credentials: List[Any], progress_callback=None) -> SecurityReport:
        report = SecurityReport()
        password_map = {}
        total_entropy = 0.0
        total_items = len(decrypted_credentials)

        for index, item in enumerate(decrypted_credentials):
            if progress_callback and total_items > 0:
                current_percent = int((index / total_items) * 90)
                progress_callback(10 + current_percent)

            pwd = item.password            
            
            # API & Strength Checks
            b_count = self.breach_checker.get_breach_count(pwd)
            item.breach_count_val = b_count 
            strength_label = self.password_analyser.evaluate_strength(pwd)
            entropy = self.password_analyser.calculate_entropy(pwd)
            total_entropy += entropy

            item.is_breached = (b_count > 0)
            item.is_weak = (strength_label == "Weak")
            item.is_reused = False 

            if pwd not in password_map:
                password_map[pwd] = []
            password_map[pwd].append(item)

        if progress_callback: progress_callback(100)

        for pwd, items_list in password_map.items():
            if len(items_list) > 1:
                for entry in items_list:
                    entry.is_reused = True
                    other_titles = [e.title for e in items_list if e.id != entry.id]
                    if not other_titles:
                         other_titles = [e.title for e in items_list if e is not entry]

                    entry.reused_on_list = ", ".join(other_titles)

        for item in decrypted_credentials:
            if item.is_breached:
                report.breached_count += 1
                report.breached_credentials.append(item)
            
            if item.is_weak:
                report.weak_count += 1
                report.weak_credentials.append(item)

            if item.is_reused:
                report.reused_count += 1
                report.reused_credentials.append(item)
        
        if total_items > 0:
            report.average_entropy = total_entropy / total_items

        return report

    def format_json_response(self, report, total_items) -> dict:
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