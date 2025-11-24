# # app/agents/tools/investment_tools.py
# from langgraph.prebuilt import Tool
# from app.services.investment_services import (
#     create_investment,
#     get_investments,
#     update_investment_value
# )

# def create_investment_fn(user_id: int, instrument_type: str, symbol: str, quantity: float, avg_price: float):
#     """Create a new investment entry."""
#     return create_investment(user_id, instrument_type, symbol, quantity, avg_price)

# def get_investments_fn(user_id: int):
#     """Retrieve all investments for a user."""
#     return get_investments(user_id)

# def update_investment_value_fn(investment_id: int, new_value: float):
#     """Update market value of an investment."""
#     return update_investment_value(investment_id, new_value)


# create_investment_tool = Tool(
#     name="create_investment",
#     description="Create an investment for a user. Args: user_id, instrument_type, symbol, quantity, avg_price.",
#     func=create_investment_fn,
# )

# get_investments_tool = Tool(
#     name="get_investments",
#     description="Retrieve all investments for a user. Args: user_id.",
#     func=get_investments_fn,
# )

# update_investment_value_tool = Tool(
#     name="update_investment_value",
#     description="Update an investment's current market value. Args: investment_id, new_value.",
#     func=update_investment_value_fn,
# )
