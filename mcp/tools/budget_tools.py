from app.config.database import SessionLocal
from app.models.budget import Budget

# functions for budget
def create_budget(user_id: int, category: str, limit: float, period: str = "monthly"):
    print("[DEBUG] create_budget:", user_id, category, limit, period)
    db = SessionLocal()
    try:
        budget = Budget(
            user_id=user_id,
            category=category,
            limit=limit,
            period=period
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


def get_budgets(user_id: int):
    db = SessionLocal()
    try:
        budgets = db.query(Budget).filter(Budget.user_id == user_id).all()
        return [
            {
                "id": b.id,
                "category": b.category,
                "limit": b.limit,
                "current_spend": b.current_spend,
                "period": b.period
            }
            for b in budgets
        ]
    finally:
        db.close()


def update_budget_spend(budget_id: int, amount: float):
    db = SessionLocal()
    try:
        budget = db.query(Budget).filter(Budget.id == budget_id).first()
        if not budget:
            return {"status": "error", "message": "Budget not found"}

        budget.current_spend += amount
        db.commit()
        return {"status": "success", "new_spend": budget.current_spend}
    except Exception as e:
        db.rollback()
        return {"status": "error", "message": str(e)}
    finally:
        db.close()
