from langgraph.prebuilt import Tool
from config.database import SessionLocal
from models.transaction import Transaction


def create_transaction_fn(
    user_id: int,
    amount: float,
    category: str = None,
    raw_description: str = None,
):
    db = SessionLocal()
    try:
        tx = Transaction(
            user_id=user_id,
            amount=amount,
            category=category,
            raw_description=raw_description
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


def get_transactions_fn(user_id: int, limit: int = 20):
    db = SessionLocal()
    try:
        txs = (
            db.query(Transaction)
            .filter(Transaction.user_id == user_id)
            .order_by(Transaction.timestamp.desc())
            .limit(limit)
            .all()
        )

        return [
            {
                "id": t.id,
                "amount": t.amount,
                "category": t.category,
                "raw_description": t.raw_description,
                "timestamp": str(t.timestamp),
                "is_recurring": t.is_recurring,
            }
            for t in txs
        ]
    finally:
        db.close()


create_transaction_tool = Tool(
    name="create_transaction",
    description="Record a financial transaction for a user.",
    func=create_transaction_fn,
)

get_transactions_tool = Tool(
    name="get_transactions",
    description="Fetch recent transactions for a user.",
    func=get_transactions_fn,
)
