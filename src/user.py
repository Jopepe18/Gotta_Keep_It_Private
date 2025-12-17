from dataclasses import dataclass
from datetime import datetime
from typing import Optional

class User:
    """
    registered user in the database.
    """
    user_id: str            # Unique ID (UUID)
    username: str           # Unique Username
    email: str              # email
    main_password: str      # Encrypted/Hashed Password
    secret_key: str         # User's Secret Key
    is_verified: bool       # Email verification status
    
    password_reset_token: Optional[str] = None    # Temporary token for password reset
    reset_token_expiry: Optional[datetime] = None # When the reset token expires

    def __init__(self, user_id: str, username: str, email: str, password_hash: str, secret_key: str):
        self.user_id = user_id
        self.username = username
        self.email = email
        self.main_password = password_hash
        self.secret_key = secret_key
        self.is_verified = False  # Default to False until verified
        self.password_reset_token = None
        self.reset_token_expiry = None
