from mcp.tools.budget_tools import (
    create_budget,
    get_budgets,
    update_budget_spend
)
from app.mcp.agents.base_agent import BaseAgent

class BudgetAgent(BaseAgent):
    def __init__(self):
        super().__init__("BudgetAgent")

    def run(self, state: dict):
        print("[DEBUG] state received:", state)

        intent = state["intent"]
        params = state["params"]

        if intent == "set_budget":
            # map intent output → create_budget inputs
            return create_budget(
                user_id=1,                   # <- FIX: you must supply a user id
                category="general",          # <- FIX: extract from text or assume default
                limit=params["amount"],      # <- map amount → limit
                period="monthly"
            )

        elif intent == "get_budgets":
            return get_budgets(user_id=1)

        elif intent == "update_spend":
            return update_budget_spend(
                budget_id=params["budget_id"],
                amount=params["amount"]
            )

        else:
            return {"error": "Unknown budget intent"}
