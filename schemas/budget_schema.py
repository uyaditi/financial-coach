from pydantic import BaseModel

class BudgetCreate(BaseModel):
    category: str
    max_limit: float

class BudgetUpdate(BaseModel):
    max_limit: float

class BudgetResponse(BaseModel):
    id: int
    category: str
    max_limit: float
    time_period: str

    class Config:
        orm_mode = True
