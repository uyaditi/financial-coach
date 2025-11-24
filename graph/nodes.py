from langchain.tools import tool

from mcp.tools.budget_tools import (
    create_budget,
    get_budgets,
    update_budget_spend
)
from mcp.tools.payment_tools import execute_payment

@tool
def create_budget_tool(user_id: int, category: str, limit: float, period: str = "monthly"):
    """Create a new budget for a user."""
    return create_budget(user_id, category, limit, period)


@tool
def get_budgets_tool(user_id: int):
    """Get all budgets for a user."""
    return get_budgets(user_id)


@tool
def update_budget_spend_tool(budget_id: int, amount: float):
    """Update spending under a budget."""
    return update_budget_spend(budget_id, amount)

@tool
def payment_tool(amount: float, payee: str):
    """Send a payment to a payee"""
    return execute_payment(amount, payee)
