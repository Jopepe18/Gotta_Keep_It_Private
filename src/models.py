from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class UserModel(Base):
    __tablename__ = 'users'

    user_id = Column(String, primary_key=True)
    username = Column(String, unique=True, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    secret_key = Column(String, nullable=False)
    is_verified = Column(Boolean, default=False)
    
    password_reset_token = Column(String, nullable=True)
    reset_token_expiry = Column(DateTime, nullable=True)
