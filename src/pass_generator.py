import secrets
import string
import random
from typing import Optional, Dict
import hashlib
import getpass

#CLI Interface. υλοποιημένο με front end στο generator_backend.py

class PasswordGenerator:
    def __init__(self):
        self.lowercase = string.ascii_lowercase
        self.uppercase = string.ascii_uppercase
        self.digits = string.digits
        self.special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        
    def generate_strong_password(self, length: int = 16) -> str:
        #λαχιστο μακρος κωδικου
        if length < 12:
            length = 12
       
       # συνδυασμος χαρακτήρων
        all_chars = self.lowercase + self.uppercase + self.digits + self.special_chars
        
        # να εχουμε τουλαχιστον ενα χαρακτηρα απο όλα
        password_chars = [
            secrets.choice(self.lowercase),
            secrets.choice(self.uppercase),
            secrets.choice(self.digits),
            secrets.choice(self.special_chars)
        ]
        
        #random characters 
        for _ in range(length - 4):
            password_chars.append(secrets.choice(all_chars))
        
        # shuffle
        random.shuffle(password_chars)
        
        return ''.join(password_chars)

class PasswordManager:
    def __init__(self):
        self.generator = PasswordGenerator()
        self.vault = {} 
        self.current_password = None
        
    def activate_password_generation(self, source: str) -> None:
        print(f"\n{'='*50}")
        print(f"Password Generator Activated from: {source}")
        print(f"{'='*50}")
        
        # φτιαχνουμε τον κωδικο
        self.current_password = self.generator.generate_strong_password()
        
        # δειχνουμε τον κωδικο και τον επιβεβαιωνουμε
        self.show_password_in_field()
        self.confirm_and_save()
    
    def show_password_in_field(self) -> None:
        print(f"\nGenerated Password: {self.current_password}")
        print(f"Password Strength: {self.assess_password_strength(self.current_password)}")
        print(f"Password Length: {len(self.current_password)}")
        
    
    def confirm_and_save(self) -> None:

        print("\n--- Confirm Password ---")
        print("Options:")
        print("1. Confirm and Save Password")
        print("2. Regenerate New Password")
        print("3. Abort Process (Don't Save)")
        
        try:
            choice = int(input("\nEnter your choice: "))
            
            if choice == 1:
                self.save_to_vault()
            elif choice == 2:
                self.regenerate_password()
            elif choice == 3:
                self.abort_process()
            else:
                print("Invalid choice. Try again.")
                self.confirm_and_save()
                
        except ValueError:
            print("Please enter a valid number.")
            self.confirm_and_save()
    
    def save_to_vault(self, service_name: Optional[str] = None) -> None: #αποθηκευση κωδικου στο vault
        if not self.current_password:
            print("No password to save!")
            return
        
        if not service_name:
            service_name = input("Enter service/website name: ")
        
        username = input("Enter username/email: ")
        
        entry = {
            'password': self.current_password,
            'username': username,
            'strength': self.assess_password_strength(self.current_password),
            'length': len(self.current_password),
            'timestamp': self.get_timestamp()
        }
        
        self.vault[service_name] = entry
        print(f"\n✓ Password saved for {service_name}!")
        print(f"Entry ID: {self.generate_entry_id(service_name, username)}")
        
        # Reset current password
        self.current_password = None
    
    def regenerate_password(self) -> None: #Regenerate a new password.
        print("\n--- Generating new password ---")
        self.current_password = self.generator.generate_strong_password()
        self.show_password_in_field()
        self.confirm_and_save()
    
    def abort_process(self) -> None:
        print("\n Process aborted. Password not saved.")
        self.current_password = None
    
    @staticmethod
    def assess_password_strength(password: str) -> str:
        """Assess password strength."""
        score = 0
        length = len(password)
        
        # Ελεγχος για μηκος κωδικου
        if length >= 16:
            score += 3
        elif length >= 12:
            score += 2
        elif length >= 8:
            score += 1
        
        # Ελεγχος ποικιλιας χαρακτήρων
        if any(c.islower() for c in password):
            score += 1
        if any(c.isupper() for c in password):
            score += 1
        if any(c.isdigit() for c in password):
            score += 1
        if any(c in string.punctuation for c in password):
            score += 1
        
        # κλασσικες περιπτωσες κωωδδικων
        weak_passwords = {'password', '123456', 'helloooo', 'admin', 'welcome'}
        
        if password.lower() in weak_passwords:
            score = 0
        
        # Αξιολογηση
        if score >= 6:
            return "Very Strong"
        elif score >= 4:
            return "Strong"
        elif score >= 3:
            return "Moderate"
        else:
            return "Weak"
    
    @staticmethod
    def show_password_composition(password: str) -> None:
        """Show the character composition of the password."""
        counts = {
            'Lowercase': sum(1 for c in password if c.islower()),
            'Uppercase': sum(1 for c in password if c.isupper()),
            'Digits': sum(1 for c in password if c.isdigit()),
            'Special': sum(1 for c in password if c in string.punctuation)
        }
        
        print("\nCharacter Composition:")
        for char_type, count in counts.items():
            print(f"  {char_type}: {count}")
    
    @staticmethod
    def generate_entry_id(service: str, username: str) -> str: #unique ID for the vault entry
        combined = f"{service}:{username}:{secrets.token_hex(4)}"
        return hashlib.sha256(combined.encode()).hexdigest()[:12]
    
    @staticmethod
    def get_timestamp() -> str:
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    
    def view_vault_summary(self) -> None:
        """Display a summary of saved passwords."""
        if not self.vault:
            print("\nVault is empty.")
            return
        
        print(f"\n{'='*50}")
        print(f"Password Vault Summary ({len(self.vault)} entries)")
        print(f"{'='*50}")
        
        for service, entry in self.vault.items():
            print(f"\nService: {service}")
            print(f"  Username: {entry['username']}")
            print(f"  Strength: {entry['strength']}")
            print(f"  Length: {entry['length']}")
            print(f"  Saved: {entry['timestamp']}")

