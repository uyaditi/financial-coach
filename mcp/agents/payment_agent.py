from app.mcp.agents.base_agent import BaseAgent
from app.mcp.tools.payment_tools import execute_payment


class PaymentAgent(BaseAgent):
    def __init__(self):
        super().__init__("PaymentAgent")
        self.tools = {
            "execute_payment": execute_payment
        }

    def run(self, instruction: str, **kwargs):
        """
        The agent receives an instruction like:
        - instruction="execute_payment", amount=500, payee="Aditi"
        """
        tool = self.tools.get(instruction)

        if not tool:
            return {"error": f"Unknown instruction: {instruction}"}

        # Call the LangGraph Tool function
        return tool.func(**kwargs)
