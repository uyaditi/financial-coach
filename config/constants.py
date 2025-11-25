# Constants for investment-related prompts and configurations

PROMPT_TEMPLATES = {
    "portfolio_optimize": "Suggest how to optimize the portfolio to save for a goal worth {expenses}.",
    "stock_pnl": "What is the profit/loss for {stock} in the portfolio?",
    "portfolio_value": "What is the total value of the portfolio?",
    "portfolio_strategy": "Suggest a strategy to maximize returns for the current portfolio.",
    "portfolio_advice": "Provide one actionable investment advice for the portfolio.",
    "portfolio_rebalancing": "How should the portfolio be rebalanced to reduce risk?",
    "portfolio_review": "Summarize the strengths and weaknesses of the portfolio."
}

# Dynamic stock names (can be fetched from investments.json or other sources)
DYNAMIC_STOCKS = [
    "reliance", "tata", "infy", "tcs", "hdfc", "sbin", "icici", "axis", "bajfinance", "kotak"
]