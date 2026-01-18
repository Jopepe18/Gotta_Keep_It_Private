import math
import os
from typing import Set

class PasswordAnalyser:
    def __init__(self):    
        self.dictionary: Set[str] = set()
        self.dictionary_loaded: bool = False
        # Βεβαιώσου ότι το όνομα του αρχείου είναι σωστό στον φάκελο!
        currentDir = os.path.dirname(os.path.abspath(__file__))
        filepath = os.path.join(currentDir, '100k-most-used-passwords-NCSC.txt')   
        self.load_dictionary(filepath)

    # ΑΦΑΙΡΕΣΑ την κάτω παύλα (_) για να καλείται ελεύθερα
    def calculate_entropy(self, password):
        pool_size = 0
        if any(c.islower() for c in password): pool_size += 26
        if any(c.isupper() for c in password): pool_size += 26
        if any(c.isdigit() for c in password): pool_size += 10
        if any(not c.isalnum() for c in password): pool_size += 32
        if any(ord(c) > 127 for c in password): pool_size += 50 
        
        if pool_size == 0: return 0
        return len(password) * math.log2(pool_size)

    def load_dictionary(self, filepath: str) -> None:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                self.dictionary = {line.strip() for line in f}
            self.dictionary_loaded = True
            print(f"Dictionary loaded: {len(self.dictionary)} passwords.")
        except FileNotFoundError:
            print("Dictionary file not found. Skipping dictionary check.")
            self.dictionary_loaded = False

    def check_in_dictionary(self, password: str) -> bool:
        if not self.dictionary_loaded:
            return False
        return password in self.dictionary

    def evaluate_strength(self, password: str) -> str: 
        # 1. Πρώτα έλεγχος μήκους
        if len(password) < 8:
            return "Weak"
            
        # 2. Μετά έλεγχος Λεξικού (Σημαντικό!)
        if self.check_in_dictionary(password):
            return "Weak"

        # 3. Τέλος έλεγχος Entropy
        entropy = self.calculate_entropy(password)
        if entropy < 40:
             return "Weak"
        elif entropy < 60:
             return "Medium"
        elif entropy< 80:
             return "Strong"
        else:
             return "Excellent"