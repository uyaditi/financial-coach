# from langgraph.prebuilt import Tool
# from app.services.portfolio import portfolio_summary
# from app.services.risk import risk_profile
# from app.services.investment_services import get_investments


# def portfolio_summary_fn(user_id: int):
#     """Summaries total portfolio metrics for a user."""
#     investments = get_investments(user_id)
#     return portfolio_summary(investments)


# def portfolio_risk_fn(user_id: int, history_values: list = None):
#     """Calculates diversification, volatility, and risk score."""
#     investments = get_investments(user_id)
#     return risk_profile(investments, history_values)


# portfolio_summary_tool = Tool(
#     name="portfolio_summary",
#     description="Get full portfolio summary: pnl, returns, allocation.",
#     func=portfolio_summary_fn
# )

# portfolio_risk_tool = Tool(
#     name="portfolio_risk",
#     description="Get risk analysis: diversification, volatility, high-risk weight.",
#     func=portfolio_risk_fn
# )