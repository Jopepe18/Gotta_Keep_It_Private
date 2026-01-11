from typing import Optional
from datetime import datetime, timedelta
import uuid

from sqlalchemy.orm import Session
from database import SessionLocal, engine
from models import UserModel, Base

from dtos import (
    RegistrationRequest, RegistrationResult,
    LoginRequest, AuthenticationResult,
    RecoveryVerificationRequest, RecoveryVerificationResult,
    RecoveryChangeRequest
)
# 
#  "users_db: list[User]". not used (yet)
# 

from Key_Manager import KeyManager
from encryption_service import EncryptionService

class AuthenticationManager:
    """
    Manages user authentication, registration, and password management using SQLite.
    """
    encrypt_service: EncryptionService
    key_manager: KeyManager

    def __init__(self):
        self.encrypt_service = EncryptionService()
        self.key_manager = KeyManager()
        # Create tables if they don't exist
        Base.metadata.create_all(bind=engine)

    def get_db(self):
        return SessionLocal()

    def register_user(self, request: RegistrationRequest) -> RegistrationResult:
        db: Session = self.get_db()
        try:
            # 1. Check if email or username exists
            existing_email = db.query(UserModel).filter(UserModel.email == request.email).first()
            if existing_email:
                return RegistrationResult(success=False, msg="Email already exists")
            
            existing_user = db.query(UserModel).filter(UserModel.username == request.username).first()
            if existing_user:
                return RegistrationResult(success=False, msg="Username already exists")

            # 2. Check passwords match
            if request.password != request.confirm_password:
                return RegistrationResult(success=False, msg="Passwords do not match")

            # 3. Hash password
            hashed_pw = self.encrypt_service.hash_password(request.password)

            # 4. Generate Secret Key
            secret_key = self.key_manager.generate_secret_key()

            # 5. Create new User
            new_user_id = str(uuid.uuid4())#random user id generated
            new_user = UserModel(
                user_id=new_user_id, 
                username=request.username, 
                email=request.email, 
                password_hash=hashed_pw, 
                secret_key=secret_key,
                is_verified=False
            )
            db.add(new_user)
            db.commit()
            db.refresh(new_user)

            # 6. Return Success with Secret Key
            return RegistrationResult(success=True, msg="Success", user_id=new_user_id, secret_key=secret_key)
        finally:
            db.close()

    def login(self, request: LoginRequest) -> AuthenticationResult:
        db: Session = self.get_db()
        try:
            # 1. Find User by Username
            found_user = db.query(UserModel).filter(UserModel.username == request.username).first()
            
            if not found_user:
                return AuthenticationResult(success=False, message="User not found")

            # 2. Verify password
            if self.encrypt_service.verify_password(request.password, found_user.password_hash):
                # 3. Success -> Generate Token
                token = self.key_manager.generate_token()
                # Check if user has vaults
                has_vault = len(found_user.vaults) > 0
                return AuthenticationResult(success=True, message="Login Successful", token=token, secret_key=found_user.secret_key, user_id=found_user.user_id, has_vault=has_vault)
            else:
                return AuthenticationResult(success=False, message="Invalid credentials")
        finally:
            db.close()



    def verify_recovery_info(self, request: RecoveryVerificationRequest) -> RecoveryVerificationResult:
        db: Session = self.get_db()
        try:
            # Check for user matching ALL : username, email, secret_key
            user = db.query(UserModel).filter(
                UserModel.username == request.username,
                UserModel.email == request.email,
                UserModel.secret_key == request.secret_key
            ).first()

            if user:
                return RecoveryVerificationResult(success=True, message="Match")
            else:
                return RecoveryVerificationResult(success=False, message="No Match")
        finally:
            db.close()

    def execute_password_recovery(self, request: RecoveryChangeRequest) -> bool:
        db: Session = self.get_db()
        try:
            # 1. Verify Identity again (για Extra Security)
            user = db.query(UserModel).filter(
                UserModel.username == request.username,
                UserModel.secret_key == request.secret_key
            ).first()

            if not user:
                return False

            # 2. Check Passwords Match
            if request.new_password != request.confirm_password:
                return False

            # 3. Update Password
            user.password_hash = self.encrypt_service.hash_password(request.new_password)
            db.commit()
            return True
        finally:
            db.close()
