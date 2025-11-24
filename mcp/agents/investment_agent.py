from services.portfolio import get_stock_investments, portfolio_summary
from langchain_groq import ChatGroq
import os
from config.constants import PROMPT_TEMPLATES


class InvestmentAgent:
    def __init__(self):
        self.model_name = os.getenv("MODEL_NAME")
        self.api_key = os.getenv("GROQ_API_KEY")
        if not self.model_name or not self.api_key:
            raise ValueError("MODEL_NAME or GROQ_API_KEY missing in environment variables.")
        self.llm = ChatGroq(model_name=self.model_name, api_key=self.api_key, temperature=0.2)

    def run(self, state: dict):
        intent = state.get("intent")
        params = state.get("params", {})
        user_id = 1  # static for mock
        holdings_data = get_stock_investments(user_id)
        holdings = holdings_data.get("holdings", [])

        # Prepare context for LLM
        context = f"User holdings: {holdings}\nIntent: {intent}\nParams: {params}"
        prompt = None
        if intent in PROMPT_TEMPLATES:
            prompt = context + "\n" + PROMPT_TEMPLATES[intent].format(**params)

        if prompt:
            try:
                response = self.llm.invoke(prompt)
                return {"result": response.content}
            except Exception as e:
                return {"result": f"AI error: {e}"}
        return {"result": "Sorry, I didn't understand your investment request."}
