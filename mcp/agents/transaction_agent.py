from mcp.agents.base_agent import BaseAgent

from mcp.tools.transaction_tools import (
    create_expense_tool,
    create_income_tool,
    get_transactions_tool,
    update_transaction_tool,
    delete_transaction_tool,
)

class TransactionAgent(BaseAgent):
    def __init__(self):
        super().__init__("TransactionAgent")

    def run(self, state: dict):
        print("[DEBUG] TransactionAgent received:", state)

        intent = state["intent"]
        p = state["params"]

        if intent == "create_expenses":
            return {
                "result": create_expense_tool(
                    user_id=1,
                    amount=p["amount"],
                    category=p["category"] or "miscellaneous",
                    payee=p["payee"],
                    raw_description=p["raw_description"],
                    is_recurring=p["is_recurring"],
                )
            }

        elif intent == "create_income":
            return {
                "result": create_income_tool(
                    user_id=1,
                    amount=p["amount"],
                    category=p["category"] or "",
                    payee=p["payee"],
                    raw_description=p["raw_description"],
                    is_recurring=p["is_recurring"],
                )
            }

        elif intent == "get_transactions":
            return {
                "result": get_transactions_tool(
                    user_id=1,
                    type=p.get("type"),
                    category=p.get("category")
                )
            }

        elif intent == "update_transaction":
            return {
                "result": update_transaction_tool(
                    category=p["category"],
                    amount=p["amount"],
                    date_str=p["raw_description"],  # or params["timestamp"] if available
                    type=p.get("type", "expense")
                )
            }

        elif intent == "delete_transaction":
            return {
                "result": delete_transaction_tool(
                    category=p["category"],
                    date_str=p["raw_description"],
                    type=p.get("type", "expense")
                )
            }

        return {"result": "Sorry, I did not understand your transaction request."}
