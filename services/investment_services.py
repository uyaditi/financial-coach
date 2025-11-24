# app/services/investments.py
from app.config.database import SessionLocal
from app.models.investment import Investment

def create_investment(user_id: int, instrument_type: str, symbol: str, quantity: float, avg_price: float):
    db = SessionLocal()
    try:
        investment = Investment(
            user_id=user_id,
            instrument_type=instrument_type,
            symbol=symbol,
            quantity=quantity,
            avg_price=avg_price,
            current_value=quantity * avg_price
        )
        db.add(investment)
        db.commit()
        db.refresh(investment)
        return {"status": "success", "investment_id": investment.id}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def get_investments(user_id: int):
    db = SessionLocal()
    try:
        invs = db.query(Investment).filter(Investment.user_id == user_id).all()
        return [
            {
                "id": i.id,
                "instrument_type": i.instrument_type,
                "symbol": i.symbol,
                "quantity": i.quantity,
                "avg_price": i.avg_price,
                "current_value": i.current_value
            }
            for i in invs
        ]
    finally:
        db.close()


def update_investment_value(investment_id: int, new_value: float):
    db = SessionLocal()
    try:
        inv = db.query(Investment).filter(Investment.id == investment_id).first()
        if not inv:
            return {"status": "error", "message": "Investment not found"}

        inv.current_value = new_value
        db.commit()
        return {"status": "success", "new_value": new_value}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()
