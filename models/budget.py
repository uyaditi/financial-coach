from sqlalchemy import Column, Integer, Float, String, ForeignKey
from sqlalchemy.orm import relationship
from config.database import Base
# from app.models.users import User

class Budget(Base):
    __tablename__ = "budgets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    category = Column(String, nullable=False)
    max_limit = Column(Float, nullable=False)
    time_period = Column(String, default="monthly")

    user = relationship("User", back_populates="budgets")
