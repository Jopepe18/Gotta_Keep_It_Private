import hashlib
import secrets
import base64

class EncryptionService:
    """
     this is a helper class for cryptographic operations.
    """

    def hash_password(self, plain_password: str) -> str:
        """
        Hashes a plain text password using SHA-256 (for simplicity/portability).
        """
        
        
        # A simple secure implementation using PBKDF2
        salt = secrets.token_hex(16)
        return self._hash_with_salt(plain_password, salt)

    def _hash_with_salt(self, password: str, salt: str) -> str:
        # Format: "salt$hash"
        dk = hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 100000)
        return f"{salt}${dk.hex()}"

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """
        Verifies if the provided plain password matches the hashed password.
        """
        try:
            salt, stored_hash = hashed_password.split('$')
            new_hash_full = self._hash_with_salt(plain_password, salt)
            return new_hash_full == hashed_password
        except ValueError:
            # Malformed hash
            return False

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
        raw = secrets.token_hex(8).upper() # 16 chars
        return f"{raw[:4]}-{raw[4:8]}-{raw[8:12]}-{raw[12:]}"
