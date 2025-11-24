import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression


# ----------MATH BASED---------------

# def forecast_cashflow_next_month(
#         expenses_df: pd.DataFrame,
#         income_streams: list,
#         investments: list,
#         loans: list,
#         budget: dict,
#         starting_balance: float
#     ):
#     """
#     Forecasts daily cashflow for the next 30 days.

#     Parameters:
#     ----------
#     expenses_df : DataFrame with columns ["date", "amount", "category"]
#     income_streams : list of dicts -> {"name": str, "amount": float, "credit_day": int, "frequency": "monthly"}
#     investments : list of dicts -> {"name": str, "amount": float, "day": int}
#     loans : list of dicts -> {"type": str, "emi": float, "due_day": int}
#     budget : dict -> {"category": budgeted_amount}
#     starting_balance : float

#     Returns:
#     --------
#     DataFrame with daily forecast: date, inflow, outflow, balance
#     """

#     today = datetime.today().date()
#     next_30_days = [today + timedelta(days=i) for i in range(30)]

#     forecast = pd.DataFrame({
#         "date": next_30_days,
#         "inflow": 0.0,
#         "outflow": 0.0
#     })

#     # 1. FIXED INFLOWS (salary etc.)
#     for inc in income_streams:
#         for i, row in forecast.iterrows():
#             if row["date"].day == inc["credit_day"]:
#                 forecast.loc[i, "inflow"] += inc["amount"]


#     # 2. FIXED OUTFLOWS (EMIs, SIPs)
#     for loan in loans:
#         for i, row in forecast.iterrows():
#             if row["date"].day == loan["due_day"]:
#                 forecast.loc[i, "outflow"] += loan["emi"]

#     for inv in investments:
#         for i, row in forecast.iterrows():
#             if row["date"].day == inv["day"]:
#                 forecast.loc[i, "outflow"] += inv["amount"]

#     # 3. VARIABLE EXPENSE FORECASTING (averages)
#     avg_by_cat = (
#         expenses_df
#         .groupby("category")
#         .agg({"amount": "mean"})
#         .to_dict()["amount"]
#     )

#     daily_variable_spend = sum(avg_by_cat.values()) / 30

#     forecast["outflow"] += daily_variable_spend

#     # 4. Running Balance
#     balance = starting_balance
#     balances = []

#     for _, row in forecast.iterrows():
#         balance = balance + row["inflow"] - row["outflow"]
#         balances.append(balance)

#     forecast["balance"] = balances

#     return forecast



# -----------HYBRID------------------
def forecast_variable_expenses(expenses_df):
    """
    Returns projected daily variable spend based on:
    - EMA (smooths short-term fluctuations)
    - Trend via linear regression (captures rising/falling pattern)
    """

    # Daily total spending
    daily = expenses_df.groupby("date")["amount"].sum().reset_index()
    daily.sort_values("date", inplace=True)

    # --- EMA ---
    ema = daily["amount"].ewm(alpha=0.4).mean().iloc[-1]

    # --- Trend (Linear Regression) ---
    daily["t"] = np.arange(len(daily))
    model = LinearRegression()
    model.fit(daily[["t"]], daily["amount"])
    trend = model.coef_[0]   # daily change

    # Final estimated daily variable cost for next 30 days
    daily_proj = ema + trend * 15   # mid-month projection

    return float(max(daily_proj, 0))


def forecast_cashflow_next_month(
    expenses_df,
    income_streams,
    investments,
    loans,
    budget,
    starting_balance
):

    today = datetime.today().date()
    next_30 = [today + timedelta(days=i) for i in range(30)]

    df = pd.DataFrame({
        "date": next_30,
        "inflow": 0.0,
        "outflow": 0.0
    })


    # FIXED INFLOWS (salary etc.)
    for inc in income_streams:
        for i, row in df.iterrows():
            if row["date"].day == inc["credit_day"]:
                df.loc[i, "inflow"] += inc["amount"]

    # FIXED EXPENSES (EMI, SIP)
    for loan in loans:
        for i, row in df.iterrows():
            if row["date"].day == loan["due_day"]:
                df.loc[i, "outflow"] += loan["emi"]

    for inv in investments:
        for i, row in df.iterrows():
            if row["date"].day == inv["day"]:
                df.loc[i, "outflow"] += inv["amount"]

    # VARIABLE EXPENSE FORECAST
    daily_var_spend = forecast_variable_expenses(expenses_df)
    df["outflow"] += daily_var_spend

    # RUNNING BALANCE
    bal = starting_balance
    balances = []

    for _, row in df.iterrows():
        bal = bal + row["inflow"] - row["outflow"]
        balances.append(bal)

    df["balance"] = balances
    return df