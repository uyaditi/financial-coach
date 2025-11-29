from pydantic import BaseModel
from datetime import date
from typing import Optional

class DebtBase(BaseModel):
    loan_type: str
    lender: Optional[str] = None
    principal_amount: float
    outstanding_amount: float
    emi_amount: float
    emi_due_day: int
    emis_paid: int = 0
    emis_missed: int = 0
    start_date: date
    end_date: Optional[date] = None
    status: str = "active"

class DebtCreate(DebtBase):
    user_id: int

class DebtUpdate(BaseModel):
    loan_type: Optional[str] = None
    lender: Optional[str] = None
    principal_amount: Optional[float] = None
    outstanding_amount: Optional[float] = None
    emi_amount: Optional[float] = None
    emi_due_day: Optional[int] = None
    emis_paid: Optional[int] = None
    emis_missed: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = None

class DebtResponse(DebtBase):
    id: int
    user_id: int

    class Config:
        orm_mode = True
