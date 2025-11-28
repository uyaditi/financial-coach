from sqlalchemy import Column, Integer, Float, String, ForeignKey, DateTime, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from config.database import Base

class Transaction(Base):
    __tablename__ = "transactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    type = Column(String, nullable=False, default="expense")
    amount = Column(Float, nullable=False)
    category = Column(String, default="miscellaneous")
    raw_description = Column(String)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    is_recurring = Column(Boolean, default=False)
    payee = Column(String)

    user = relationship("User", back_populates="transactions")
