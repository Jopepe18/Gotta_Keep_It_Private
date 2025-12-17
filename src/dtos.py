from dataclasses import dataclass
from typing import Optional

# --- Requests (Inputs) ---

@dataclass
class RegistrationRequest:
    """Used for registering a new user."""
    username: str
    email: str
    password: str
    confirm_password: str

@dataclass
class LoginRequest:
    """Used for user login."""
    username: str
    password: str



# --- Results (Outputs) ---

@dataclass
class RegistrationResult:
    """Returned after a registration attempt."""
    success: bool
    msg: str
    user_id: Optional[str] = None
    secret_key: Optional[str] = None

@dataclass
class AuthenticationResult:
    """Returned after a login attempt."""
    success: bool
    message: str
    token: Optional[str] = None
    secret_key: Optional[str] = None

@dataclass
class RecoveryVerificationRequest:
    """Used for verifying user identity for password recovery."""
    username: str
    email: str
    secret_key: str

@dataclass
class RecoveryVerificationResult:
    """Returned after a recovery verification attempt."""
    success: bool
    message: str

@dataclass
class RecoveryChangeRequest:
    """Used to change password after verifying recovery info."""
    username: str
    secret_key: str
    new_password: str
    confirm_password: str
