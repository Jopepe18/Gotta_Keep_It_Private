import hashlib
import secrets
import base64
import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

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

    def encrypt_data(self, data: str | bytes, key: bytes) -> bytes:
        """
        KeyManager was previously handling encryption. Now EncryptionService does.
        Encrypts data (String or Bytes) using AES-GCM.
        
        Args:
            data: The text or bytes to encrypt.
            key: The encryption key (must be 32 bytes).
        """
        # 1. Convert to bytes if string
        if isinstance(data, str):
            data_bytes = data.encode('utf-8')
        else:
            data_bytes = data

        # 2. Create AES-GCM Instance
        aesgcm = AESGCM(key)

        # 3. Create Nonce
        nonce = os.urandom(12)

        # 4. Encrypt
        ciphertext = aesgcm.encrypt(nonce, data_bytes, None)

        # 5. Return [Nonce] + [Ciphertext]
        return nonce + ciphertext

    def decrypt_data(self, encrypted_packet: bytes, key: bytes) -> bytes:
        """
        Decrypts the data.
        Returns bytes! Decode if you need string.
        """
        try:
            # 1. Create AES-GCM Instance
            aesgcm = AESGCM(key)

            # 2. Separate Nonce from Ciphertext
            nonce = encrypted_packet[:12]
            ciphertext = encrypted_packet[12:]

            # 3. Decrypt & Verify
            plain_bytes = aesgcm.decrypt(nonce, ciphertext, None)
            
            return plain_bytes
            
        except Exception as e:
            raise ValueError("Decryption failed. Wrong Key or Corrupted Data.") from e
