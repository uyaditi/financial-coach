from sqlalchemy import Column, Integer, Float, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from config.database import Base

class Debt(Base):
    __tablename__ = "debts"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))

    loan_type = Column(String, nullable=False)
    lender = Column(String)
    principal_amount = Column(Float, nullable=False)
    outstanding_amount = Column(Float, nullable=False)
    emi_amount = Column(Float, nullable=False)
    emi_due_day = Column(Integer, nullable=False)

    emis_paid = Column(Integer, default=0)
    emis_missed = Column(Integer, default=0)

    start_date = Column(Date, nullable=False)
    end_date = Column(Date)
    status = Column(String, default="active")

    user = relationship("User", back_populates="debts")
