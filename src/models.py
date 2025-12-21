from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base
from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text 
from sqlalchemy.orm import relationship, declarative_base 
from sqlalchemy.sql import func 
import uuid 

Base = declarative_base()

class UserModel(Base):
    __tablename__ = 'users' # used for authentication

    user_id = Column(String, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    secret_key = Column(String, nullable=False)
    is_verified = Column(Boolean, default=False)
    
    password_reset_token = Column(String, nullable=True)
    reset_token_expiry = Column(DateTime, nullable=True)


def generate_uuid(): 
 return str(uuid.uuid4()) 

# ==========================================================
# TABLE: USERS 
# ========================================================== 
class UserModel(Base):
	__tablename__ = 'users_2' #not curently used, previous name "users"

user_id = Column(String(36), primary_key=True, default=generate_uuid) 
username = Column(String(50), unique=True, nullable=False) 
email = Column(String(100), unique=True, nullable=False)
password_hash = Column(String(255), nullable=False)
secret_key = Column(String(255), nullable=False)
is_verified = Column(Boolean, default=False)
created_at = Column(DateTime(timezone=True), server_default=func.now())
vaults = relationship("VaultModel", back_populates="user", cascade="all, delete-orphan") 

# ========================================================== # TABLE: VAULTS 
# # ========================================================== 
class VaultModel(Base): 
  __tablename__ = 'vaults'  
  vault_id = Column(Integer, primary_key=True, autoincrement=True)
  user_id = Column(String(36), ForeignKey('users.user_id', ondelete='CASCADE'), nullable=False)
  name = Column(String(100), default="Main Vault")
  created_at = Column(DateTime(timezone=True), server_default=func.now())
  user = relationship("UserModel", back_populates="vaults")
  passwords = relationship("PasswordEntry", back_populates="vault", cascade="all, delete-orphan")
  cards = relationship("CreditCardEntry", back_populates="vault", cascade="all, delete-orphan")
   # ========================================================== # TABLE: PASSWORDS 
   # ========================================================== 
class PasswordEntry(Base): 
    __tablename__ = 'passwords' 
    id = Column(Integer, primary_key=True, autoincrement=True) 
    vault_id = Column(Integer, ForeignKey('vaults.vault_id', ondelete='CASCADE'), nullable=False) 
    title = Column(String(100), nullable=False) 
    username = Column(String(100)) 
    website = Column(String(200)) 
    note = Column(Text, nullable=True) 
    encrypted_password = Column(Text, nullable=False) 
    encrypted_totp = Column(Text, nullable=True) 
    security_status = Column(String(20), default="UNKNOWN")
    is_favorite = Column(Boolean, default=False) 
    created_at = Column(DateTime(timezone=True), server_default=func.now()) 
    last_modified = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now()) 
    vault = relationship("VaultModel", back_populates="passwords") 
    # ========================================================== # TABLE: CREDIT CARDS 
    # # ========================================================== 
    class CreditCardEntry(Base): 
        __tablename__ = 'credit_cards' 
        id = Column(Integer, primary_key=True, autoincrement=True) 
        vault_id = Column(Integer, ForeignKey('vaults.vault_id', ondelete='CASCADE'), nullable=False) 
        title = Column(String(100), nullable=False) 
        cardholder_name = Column(String(100)) 
        card_type = Column(String(50)) 
        expiration_date = Column(String(10)) 
        note = Column(Text, nullable=True) 
        encrypted_number = Column(Text, nullable=False) 
        encrypted_cvv = Column(Text, nullable=False) 
        encrypted_pin = Column(Text, nullable=True) 
        is_favorite = Column(Boolean, default=False) 
        last_modified = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now()) 
        vault = relationship("VaultModel", back_populates="cards")
