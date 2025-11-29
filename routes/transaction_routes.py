from fastapi import APIRouter, HTTPException
from datetime import datetime

from schemas.transaction_schema import (
    ExpenseCreate,
    IncomeCreate,
    TransactionResponse,
)
from services.transaction_services import (
    create_expense,
    create_income,
    get_transactions,
    update_transaction,
    delete_transaction,
)

router = APIRouter(prefix="/transactions", tags=["Transactions"])


@router.post("/expense", response_model=dict)
def add_expense(expense: ExpenseCreate, user_id: int = 1):
    result = create_expense(
        user_id=user_id,
        amount=expense.amount,
        category=expense.category,
        payee=expense.payee,
        raw_description=expense.raw_description,
        is_recurring=expense.is_recurring,
    )
    return result


@router.post("/income", response_model=dict)
def add_income(income: IncomeCreate, user_id: int = 1):
    result = create_income(
        user_id=user_id,
        amount=income.amount,
        category=income.category,
        payee=income.payee,
        raw_description=income.raw_description,
        is_recurring=income.is_recurring,
    )
    return result


@router.get("/", response_model=dict)
def list_transactions(type: str | None = None, category: str | None = None, user_id: int = 1):
    result = get_transactions(type=type, category=category)
    return result


@router.put("/{category}/{date_str}", response_model=dict)
def modify_transaction(category: str, date_str: str, amount: float, type: str = "expense", user_id: int = 1):
    result = update_transaction(
        category=category,
        amount=amount,
        date_str=date_str,
        type=type,
    )

    if result.get("status") == "error":
        raise HTTPException(status_code=404, detail=result["message"])

    return result


@router.delete("/{category}/{date_str}", response_model=dict)
def remove_transaction(category: str, date_str: str, type: str = "expense", user_id: int = 1):
    result = delete_transaction(category=category, date_str=date_str, type=type)

    if result.get("status") == "error":
        raise HTTPException(status_code=404, detail=result["message"])

    return result
