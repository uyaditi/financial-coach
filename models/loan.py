# from sqlalchemy import Column, Integer, Float, ForeignKey, DateTime
# from sqlalchemy.sql import func
# from sqlalchemy.orm import relationship
# # from app.config.database import Base

# class Loan():
#     __tablename__ = "loans"

#     id = Column(Integer, primary_key=True, index=True)
#     user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
#     principal = Column(Float)
#     emi_amount = Column(Float)
#     interest_rate = Column(Float)
#     due_date = Column(DateTime(timezone=True), server_default=func.now())

#     user = relationship("User", back_populates="loans")
