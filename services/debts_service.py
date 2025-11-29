# app/services/debts_service.py
from sqlalchemy.orm import Session
from app.models.debts import Debt
from app.schemas.debts_schemas import DebtCreate, DebtUpdate

def get_all_debts(db: Session, user_id: int):
    return db.query(Debt).filter(Debt.user_id == user_id).all()

def get_debt(db: Session, debt_id: int):
    return db.query(Debt).filter(Debt.id == debt_id).first()

def create_debt(db: Session, debt: DebtCreate):
    db_debt = Debt(**debt.dict())
    db.add(db_debt)
    db.commit()
    db.refresh(db_debt)
    return db_debt

def update_debt(db: Session, debt_id: int, debt: DebtUpdate):
    db_debt = get_debt(db, debt_id)
    if not db_debt:
        return None
    for key, value in debt.dict(exclude_unset=True).items():
        setattr(db_debt, key, value)
    db.commit()
    db.refresh(db_debt)
    return db_debt

def delete_debt(db: Session, debt_id: int):
    db_debt = get_debt(db, debt_id)
    if not db_debt:
        return False
    db.delete(db_debt)
    db.commit()
    return True
