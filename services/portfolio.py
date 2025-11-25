from collections import defaultdict
import os
import json

def get_stock_investments(user_id):
    """
    Returns a mock API response for user's stock investments, similar to Zerodha's holdings endpoint.
    """
    json_path = os.path.join(os.path.dirname(__file__), "investments.json")
    with open(json_path, "r") as f:
        data = json.load(f)
    if data.get("user_id") == user_id:
        return data
    else:
        return {"user_id": user_id, "holdings": []}
    
def portfolio_summary(investments):
    total_cost = 0
    total_value = 0
    allocation = defaultdict(float)

    for inv in investments:
        cost = inv["quantity"] * inv["avg_price"]
        total_cost += cost
        total_value += inv["current_value"]
        allocation[inv["instrument_type"]] += inv["current_value"]

    pnl = total_value - total_cost
    returns = (pnl / total_cost) * 100 if total_cost else 0

    allocation_percent = {
        k: round((v / total_value) * 100, 2) for k, v in allocation.items()
    } if total_value else {}

    return {
        "total_cost": round(total_cost, 2),
        "total_current_value": round(total_value, 2),
        "net_pnl": round(pnl, 2),
        "returns_percent": round(returns, 2),
        "allocation": allocation_percent
    }