from sqlalchemy import Column, Integer, Float, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from datetime import datetime
from config.database import Base

def current_year_month():
    return datetime.now().strftime("%Y-%m")

class Budget(Base):
    __tablename__ = "budgets"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
    category = Column(String, nullable=False)
    max_limit = Column(Float, nullable=False)
    time_period = Column(String, default=current_year_month) 

    user = relationship("User", back_populates="budgets")

    __table_args__ = (
    UniqueConstraint("user_id", "category", "time_period", name="uq_user_month_category"),
)

