from mcp.agents.base_agent import BaseAgent
from datetime import datetime
from mcp.tools.budget_tools import (
    create_budget_tool,
    get_budgets_tool,
    update_budget_tool
)

class BudgetAgent(BaseAgent):
    def __init__(self):
        super().__init__("BudgetAgent")

    def run(self, state: dict):
        print("[DEBUG] state received:", state)

        intent = state["intent"]
        params = state["params"]

        if intent == "set_budget":
            if intent == "set_budget":
                return {
                    "result": create_budget_tool(
                        user_id=1,
                        category=params.get("category") or "miscellaneous",
                        max_limit=params.get("amount")
                    )
                }

        elif intent in ["get_budgets", "show_budgets", "list_budgets", "what are my budgets"]:
            return {
                "result": get_budgets_tool(user_id=1)
            }

        elif intent == "update_budget":
            return {
                "result": update_budget_tool(
                    user_id=1,
                    category=params.get("category") or "miscellaneous",
                    amount=params.get("amount")
                )
            }

        else:
            return {"error": "Unknown budget intent"}
