from services.budget_services import (
    create_budget,
    get_budgets,
    update_budget_limit
)
from mcp.agents.base_agent import BaseAgent
from datetime import datetime

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
                category = params["category"] if params["category"] else "miscellaneous",
                max_limit=params["amount"],      
                time_period=datetime.now().strftime("%Y-%m"),
            )

        elif intent in ["get_budgets", "show_budgets", "list_budgets", "what are my budgets"]:
            budgets = get_budgets(user_id=1)
            return {"result": budgets}

        elif intent == "update_budget":

            return update_budget_limit(
                category=params["category"] or "miscellaneous",
                amount=params["amount"]
            )

        else:
            return {"error": "Unknown budget intent"}
