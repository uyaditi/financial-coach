import numpy as np

def calculate_diversification(investments):
    types = [inv["instrument_type"] for inv in investments]
    score = len(set(types)) / max(len(investments), 1)
    return round(score * 100, 2)  # percentage

def calculate_volatility(history_values):
    if len(history_values) < 2:
        return 0
    returns = np.diff(history_values) / history_values[:-1]
    vol = np.std(returns)
    return round(float(vol), 4)

def risk_profile(investments, history_values=None):
    diversification = calculate_diversification(investments)
    volatility = calculate_volatility(history_values or [])

    risky_assets = ["crypto", "smallcap", "penny"]
    risky_weight = sum(
        inv["current_value"] for inv in investments if inv["instrument_type"] in risky_assets
    ) / max(sum(inv["current_value"] for inv in investments), 1)

    return {
        "diversification_score": diversification,
        "volatility": volatility,
        "high_risk_weight": round(risky_weight * 100, 2)
    }