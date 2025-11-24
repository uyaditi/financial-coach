from sqlalchemy import Column, Integer, ForeignKey, Float, String
from sqlalchemy.orm import relationship
from app.config.database import Base

class Savings(Base):
    __tablename__ = "savings"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    goal_amount = Column(Float, nullable=False)
    category = Column(String, nullable=False)
    curr_amount = Column(Float, default=0.0, nullable=False)
    
    user = relationship("User", back_populates="savings")
    