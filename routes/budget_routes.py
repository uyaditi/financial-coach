from fastapi import APIRouter, HTTPException
from datetime import datetime

from schemas.budget_schema import BudgetCreate, BudgetResponse, BudgetUpdate
from services.budget_services import (
    create_budget, get_budgets, update_budget_limit
)

router = APIRouter(prefix="/budgets", tags=["Budgets"])


@router.post("/", response_model=BudgetResponse)
def add_budget(budget: BudgetCreate, user_id: int = 1):
    time_period = datetime.now().strftime("%Y-%m")
    new_budget = create_budget(user_id, budget.category, budget.max_limit, time_period)
    return new_budget


@router.get("/", response_model=list[BudgetResponse])
def list_budgets(user_id: int = 1):
    return get_budgets(user_id)


@router.put("/{category}", response_model=BudgetResponse)
def modify_budget(category: str, update: BudgetUpdate, user_id: int = 1):
    time_period = datetime.now().strftime("%Y-%m")
    updated = update_budget_limit(user_id, category, update.max_limit, time_period)

    if not updated:
        raise HTTPException(status_code=404, detail="Budget not found")

    return updated
