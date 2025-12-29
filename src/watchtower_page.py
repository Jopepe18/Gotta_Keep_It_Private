import math
from typing import List, Set, Any
from Gotta_Keep_It_Private.src.dtos import SecurityReport

class Watchtower:
    def __init__(self):
        self.weak_count = 0
        self.reused_count = 0
        self.weak_passList = []    
        self.reused_passList = []  

    def _calculate_entropy(self, password):
        pool_size = 0
        
        
        if any(c.islower() for c in password): pool_size += 26
        if any(c.isupper() for c in password): pool_size += 26
        if any(c.isdigit() for c in password): pool_size += 10
        if any(not c.isalnum() for c in password): pool_size += 32
        if any(ord(c) > 127 for c in password): pool_size += 50 

        if pool_size == 0: return 0
        
        return len(password) * math.log2(pool_size)

    def __init__(self):
        
        self.dictionary: Set[str] = set()
        self.dictionary_loaded: bool = False
        

    def load_dictionary(self, filepath: str) -> None: # 
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                self.dictionary = {line.strip() for line in f}
            self.dictionary_loaded = True
            print(f"Dictionary loaded: {len(self.dictionary)} passwords.")
        except FileNotFoundError:
            print("Dictionary file not found. Skipping dictionary check.")
            self.dictionary_loaded = False

    def check_in_dictionary(self, password: str) -> bool: # 
        if not self.dictionary_loaded:
            return False
        return password in self.dictionary

    

    def evaluate_strength(self, password: str) -> str: 
        entropy = self.calculate_entropy(password)
        if entropy < 40:
            return "Weak"
        elif entropy < 60:
            return "Medium"
        else:
            return "Strong"

    def check_breach(self, password: str) -> bool: # 
        
        # pending , false for now so it doesnt need debugging 
        return False

    def analyze_vault(self, decrypted_credentials: List[Any]) -> SecurityReport:

        report = SecurityReport()
        password_temp = {} 
        total_entropy = 0.0

        

        for item in decrypted_credentials:
            pwd = item.password
            
            
            entropy = self.calculate_entropy(pwd)
            total_entropy += entropy

            
            is_weak = False
            if entropy < 40:
                is_weak = True
            if self.check_in_dictionary(pwd):
                is_weak = True 
            
            if is_weak:
                report.weak_count += 1
                report.weak_credentials.append(item)

            
            if pwd not in password_temp:
                password_temp[pwd] = []
            password_temp[pwd].append(item)

            
            if self.check_breach(pwd):
                report.breached_count += 1
                report.breached_credentials.append(item)

        for pwd, items_list in password_temp.items():
            if len(items_list) > 1:
                report.reused_count += len(items_list)
    
                report.reused_credentials.extend(items_list)

        
        if len(decrypted_credentials) > 0:
            report.average_entropy = total_entropy / len(decrypted_credentials)

        return report
