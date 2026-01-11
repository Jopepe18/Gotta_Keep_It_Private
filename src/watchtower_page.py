import math
import os
from typing import List, Set, Any
from dtos import SecurityReport
from BreachAPI import BreachAPIService

class Watchtower:
    def __init__(self):
        self.weak_count = 0
        self.reused_count = 0
        self.weak_passList = []    
        self.reused_passList = []  
        self.breach_checker = BreachAPIService()

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
        currentDir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(currentDir, '100k-most-used-passwords-NCSC.txt')    
        

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
        if len(password)<8:
            return "weak"
        entropy = self.calculate_entropy(password)
        if entropy < 40:
             return "Weak"
        elif entropy < 60:
             return "Medium"
        else:
             return "Strong"

    def analyze_vault(self, decrypted_credentials: List[Any]) -> SecurityReport:

        report = SecurityReport()
        password_temp = {} 
        total_entropy = 0.0
        
        for item in decrypted_credentials:
            pwd = item.password            
            entropy = self.calculate_entropy(pwd)
            total_entropy += entropy
            if self.breach_checker.check_pwned(pwd):
              item.security_status = "COMPROMISED"
            else:
              is_weak = False
            is_weak= (entropy < 40) or self.check_in_dictionary(pwd)
            
            if is_weak:
              item.security_status = "WEAK"
            else:
              item.security_status = "SAFE" 

        if pwd not in password_temp:
            password_temp[pwd] = []

        password_temp[pwd].append(item)

   
        for pwd, items_list in password_temp.items():
            if len(items_list) > 1:
              for entry in items_list:
                if entry.security_status != "COMPROMISED":
                     entry.security_status = "REUSED"

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
        
        if len(decrypted_credentials) > 0:
            report.average_entropy = total_entropy / len(decrypted_credentials)

        return report
