import secrets
import os
import base64
from cryptography.hazmat.primitives.kdf.argon2 import Argon2id
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

class KeyManager:
    def generate_Salt(self):
       return secrets.token_bytes(16)
       

    def generate_login_salt(self) -> str:
        return secrets.token_hex(16)
    
    def generate_token(self) -> str:
        """
        Generates a secure random string token.
        """
        return secrets.token_urlsafe(32)
    
    def generate_secret_key(self) -> str:
        """
        Generates a 16-character alphanumeric secret key.
        """
        # Format: XXXX-XXXX-XXXX-XXXX
        # Simple implementation
        raw = secrets.token_hex(16).upper() 
        
        # Το χωρίζουμε σε ομάδες των 4 για ευκολία
        raw = [raw[i:i+4] for i in range(0, len(raw), 4)]
        return "-".join(raw)
    
    def generate_DEK(self):
        return secrets.token_bytes(32)
    
    def derive_key(self, password: str, salt: bytes) -> bytes:
        """
        Μετατρέπει το password σε κλειδί 32 bytes χρησιμοποιώντας Argon2id.
        Αυτό είναι το KEK (Key Encryption Key).
        """

        kdf = Argon2id(
            salt=salt,
            length=32,          # Θέλουμε 32 bytes για AES-256
            iterations=2,       # Πόσα περάσματα (Time cost)
            lanes=4,            # Parallelism (Πόσα threads)
            memory_cost=64 * 1024, # 64MB μνήμης (Memory cost) - Σημαντικό!
            ad=None,
            secret=None
        )
        
        return kdf.derive(password.encode())