from sqlalchemy import Column, Integer, String, Float, ForeignKey, JSON
from sqlalchemy.orm import relationship
from config.database import Base
# from app.models.users import User

class Account(Base):
    __tablename__ = "accounts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    account_type = Column(String, nullable=False)   # wallet, bank, mf
    balance = Column(Float, default=0.0)
    # metadata = Column(JSON)

    user = relationship("User", back_populates="accounts")
