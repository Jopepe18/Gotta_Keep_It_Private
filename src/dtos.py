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
    user_id: Optional[str] = None
    has_vault: bool = False

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
@dataclass
class VaultCreationRequest:
    """Used for creating a new vault."""
    user_id: str
    vault_name: str
    password: str # kept for diagram compliance
    confirm_password: str

@dataclass
class VaultCreationResult:
    """Returned after vault creation attempt."""
    success: bool
    message: str
    vault_id: Optional[int] = None
    recovery_key: Optional[str] = None

@dataclass
class PasswordDTO:
    id: int
    title: str
    username: str
    website: str
    is_favorite: bool
