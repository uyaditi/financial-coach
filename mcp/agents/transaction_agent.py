from services.transaction_services import {
    create_expense,
    get_transactions, 
    delete_transaction,
    update_transaction
}
from mcp.agents.base_agent import BaseAgent
from datetime import datetime

class TransactionAgent(BaseAgent):
    def __init__(self):
        super().__init__("TransactionAgent")

    def run(self, state: dict):
        print("[DEBUG] state received:", state)

        intent = state["intent"]
        params = state["params"]

        if intent == "create_expense":
            return create_expense(
                user_id=1,
                type= "expense",
                category = params["category"] if params["category"] else "miscellaneous",
                amount = params["amount"],
                payee = params["payee"],
                raw_description = params["raw_description"],
                timestamp = datetime.now().strftime("%Y-%m-%d"),
                is_recurring = params["is_recurring"]                  
            )

        elif intent == "get_transactions":
            return get_transactions()

        elif intent == "delete_transaction":
            return delete_transaction(transaction_id=params["transaction_id"])

        elif intent == "update_transaction":
            return update_transaction(
                transaction_id=params["transaction_id"],
                category=params["category"],
                amount=params["amount"],
                raw_description=params["raw_description"],
                is_recurring=params["is_recurring"]
            )

        else:
            return {"error": "Unknown transaction intent"}