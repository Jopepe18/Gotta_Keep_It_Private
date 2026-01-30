"""
Generator Backend - Bridge between QML and PasswordGenerator
"""
from PySide6.QtCore import QObject, Signal, Slot
import secrets
import string

class GeneratorBackend(QObject):
    """
    Backend for the Password Generator page.
    Exposes password generation functionality to QML.
    """
    
    # Signal to send generated password to QML
    password_generated = Signal(str, str)  # password, strength
    
    def __init__(self, password_analyser, parent=None):
        super().__init__(parent)
        self.analyser = password_analyser
        self.lowercase = string.ascii_lowercase
        self.uppercase = string.ascii_uppercase
        self.digits = string.digits
        self.special_chars = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        self.ambiguous_chars = "0O1lI|"
    
    @Slot(int, bool, bool, bool, bool, bool)
    def generatePassword(self, length: int, use_upper: bool, use_lower: bool, 
                         use_digits: bool, use_special: bool, avoid_ambiguous: bool):
        """
        Generate a password based on the provided options.
        
        Args:
            length: Password length (will be clamped to 5-50)
            use_upper: Include uppercase letters (A-Z)
            use_lower: Include lowercase letters (a-z)
            use_digits: Include digits (0-9)
            use_special: Include special characters
            avoid_ambiguous: Avoid ambiguous characters like 0, O, 1, l, I
        """
        print(f"GeneratorBackend: Generating password with length={length}")
        
        # Clamp length
        length = max(5, min(50, length))
        
        # Build character set based on options
        char_pool = ""
        required_chars = []
        
        if use_upper:
            upper = self.uppercase
            if avoid_ambiguous:
                upper = ''.join(c for c in upper if c not in self.ambiguous_chars)
            char_pool += upper
            if upper:
                required_chars.append(secrets.choice(upper))
        
        if use_lower:
            lower = self.lowercase
            if avoid_ambiguous:
                lower = ''.join(c for c in lower if c not in self.ambiguous_chars)
            char_pool += lower
            if lower:
                required_chars.append(secrets.choice(lower))
        
        if use_digits:
            digits = self.digits
            if avoid_ambiguous:
                digits = ''.join(c for c in digits if c not in self.ambiguous_chars)
            char_pool += digits
            if digits:
                required_chars.append(secrets.choice(digits))
        
        if use_special:
            char_pool += self.special_chars
            required_chars.append(secrets.choice(self.special_chars))
        
        # If no options selected, use all
        if not char_pool:
            char_pool = self.lowercase + self.uppercase + self.digits + self.special_chars
            if avoid_ambiguous:
                char_pool = ''.join(c for c in char_pool if c not in self.ambiguous_chars)
        
        # Generate password
        password_chars = list(required_chars)
        
        remaining_length = length - len(password_chars)
        for _ in range(remaining_length):
            password_chars.append(secrets.choice(char_pool))
        
        # Shuffle to avoid predictable positions
        secrets.SystemRandom().shuffle(password_chars)
        
        password = ''.join(password_chars)
        strength = self.analyser.evaluate_strength(password)
        
        print(f"GeneratorBackend: Generated password of length {len(password)}, strength: {strength}")
        self.password_generated.emit(password, strength)
    
    @Slot()
    def generateDefaultPassword(self):
        """Generate a strong password with default settings (all options enabled)."""
        self.generatePassword(16, True, True, True, True, False)
    