from config.database import SessionLocal
from models.transaction import Transaction
from datetime import datetime, timezone
from sqlalchemy.sql import func

def create_expense(user_id: int, amount: float, payee: str = None, category: str = "miscellenous", raw_description: str = None, is_recurring: bool = False):
    db = SessionLocal()
    try: 
        tx = Transaction(
            user_id = 1, 
            type = "expense",
            amount = amount, 
            category = category,
            payee = payee,
            raw_description = raw_description,
            # timestamp = datetime.now(timezone.utc),
            is_recurring = is_recurring
        )
        db.add(tx)
        db.commit()
        db.refresh(tx)
        return {"status": "success", "transaction_id": tx.id}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def create_income(user_id: int, amount: float, payee: str = None, category: str = "", raw_description: str = None, is_recurring: bool = False):
    db = SessionLocal()
    try: 
        tx = Transaction(
            user_id = 1, 
            type = "income",
            amount = amount, 
            category = category,
            payee = payee,
            raw_description = raw_description,
            # timestamp = datetime.now(timezone.utc),
            is_recurring = is_recurring
        )
        db.add(tx)
        db.commit()
        db.refresh(tx)
        return {"status": "success", "transaction_id": tx.id}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def get_transactions(type: str = None, category: str = None): 
    db = SessionLocal()
    try: 
        query = (
            db.query(Transaction)
            .filter(Transaction.user_id == 1)
        )

        if category is not None:  
            query = query.filter(Transaction.category == category)

        if type is not None: 
            query = query.filter(Transaction.type == type)

        txs = query.order_by(Transaction.timestamp.desc()).all()

        transaction_list = [
            {
                "id": t.id, 
                "type": t.type,
                "amount": t.amount,
                "category": t.category, 
                "raw_description": t.raw_description,
                "timestamp": str(t.timestamp),
                "is_recurring": t.is_recurring
            }
            for t in txs
        ]
        return {"transaction": transaction_list}
    
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def update_transaction( category: str,amount: float, date_str: str, type: str = "expense"):
    db = SessionLocal()
    try:
        target_date = datetime.fromisoformat(date_str).date()

        tx = (db.query(Transaction).filter(Transaction.user_id == 1, Transaction.category == category, Transaction.type == type,func.date(Transaction.timestamp) == target_date).first())
        if not tx:
            return {"status": "error", "message": "Transaction not found"}
        tx.amount = amount
        db.commit()
        return {"status": "success", "transaction_id": tx.id}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def delete_transaction(category: str, date_str: str, type: str = "expense"):
    db = SessionLocal()
    try: 
        txn = (db.query(Transaction).filter(Transaction.user_id == 1, Transaction.category == category, Transaction.type == type, func.date(Transaction.timestamp) == date_str).first())
        if not txn:
            return {"status": "error", "message": "Transaction not found"}
        db.delete(txn)
        db.commit()
        return {"status": "success", "transaction_id": txn.id}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally: 
        db.close()