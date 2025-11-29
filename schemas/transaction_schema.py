from pydantic import BaseModel
from typing import Optional

class TransactionBase(BaseModel):
    amount: float
    category: Optional[str] = None
    payee: Optional[str] = None
    raw_description: Optional[str] = None
    is_recurring: bool = False

class ExpenseCreate(TransactionBase):
    pass

class IncomeCreate(TransactionBase):
    pass

class TransactionResponse(BaseModel):
    id: int
    type: str
    amount: float
    category: str
    raw_description: Optional[str]
    timestamp: str
    is_recurring: bool

    class Config:
        orm_mode = True
