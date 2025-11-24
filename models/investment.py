# from sqlalchemy import Column, Integer, Float, String, ForeignKey
# from sqlalchemy.orm import relationship
# from app.config.database import Base

# class Investment():
#     __tablename__ = "investments"

#     id = Column(Integer, primary_key=True, index=True)
#     user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"))
#     instrument_type = Column(String)  # stock, crypto, mf
#     symbol = Column(String)
#     quantity = Column(Float)
#     avg_price = Column(Float)
#     current_value = Column(Float)

#     user = relationship("User", back_populates="investments")
