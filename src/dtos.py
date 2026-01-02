from dataclasses import dataclass ,field
from typing import Optional
from datetime import datetime
from typing import List, Any 
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

@dataclass
class SecurityReport:
    weak_count: int = 0
    reused_count: int = 0
    breached_count: int = 0
    average_entropy: float = 0.0
    timestamp: datetime = field(default_factory=datetime.now)
    weak_credentials: List[Any] = field(default_factory=list)
    reused_credentials: List[Any] = field(default_factory=list)
    breached_credentials: List[Any] = field(default_factory=list)

@dataclass
class ChangeEmailRequest:
    user_id: str
    new_email: str
    current_password: str

@dataclass
class ChangeMasterPasswordRequest:
    user_id: str
    current_password: str
    new_password: str