from config.database import SessionLocal
from models.budget import Budget
from datetime import datetime

# functions for budget
def create_budget(user_id: int, category: str, max_limit: float, time_period: str = datetime.now().strftime("%Y-%m")):
    print("[DEBUG] create_budget:", user_id, category, max_limit, time_period)
    db = SessionLocal()
    try:
        budget = Budget(
            user_id=user_id,
            category=category,
            max_limit=max_limit,
            time_period=time_period
        )
        db.add(budget)
        db.commit()
        db.refresh(budget)
        print("[DEBUG] budget created:", budget)
        return {"status": "success", "budget": budget.id}
    except Exception as e:
        print("[DEBUG] error creating budget:", e)
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()


def get_budgets(user_id: int = 1):
    db = SessionLocal()
    try:
        budgets = db.query(Budget).filter(Budget.user_id == user_id).all()
        return [
            {
                "id": b.id,
                "category": b.category,
                "max_limit": b.max_limit,
                "time_period": b.time_period
            }
            for b in budgets
        ]
    finally:
        db.close()


def update_budget_limit(category: str, amount: float):
    db = SessionLocal()
    try:
        budget = db.query(Budget).filter(
            Budget.user_id == 1,
            Budget.category == category, 
            Budget.time_period == datetime.now().strftime("%Y-%m")
        ).first()
        if not budget:
            return {"status": "error", "message": "Budget not found"}

        budget.max_limit = amount
        db.commit()
        return {"status": "success", "new_spend": budget.max_limit}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()
