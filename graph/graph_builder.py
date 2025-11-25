from langgraph.graph import StateGraph
from langgraph.graph.message import add_messages

from mcp.agents.budget_agent import BudgetAgent
from mcp.agents.payment_agent import PaymentAgent
from mcp.agents.intent_agent import IntentAgent
from mcp.agents.investment_agent import InvestmentAgent
from typing import TypedDict, Any
from config.constants import DYNAMIC_STOCKS

class GraphState(TypedDict):
    input: str
    intent: str
    params: dict
    result: Any

def create_state():
    return {
        "input": "",
        "intent": "",
        "params": {},
        "result": None,
    }

def route_intent(state: GraphState):
    intent = state["intent"]

    if intent in ["set_budget", "update_budget, get_budgets"]:
        return {"next": "budget"}
    elif intent == "send_money":
        return {"next": "payment"}
    elif intent in [
        "portfolio_value", "stock_pnl", "portfolio_optimize", "portfolio_strategy",
        "portfolio_advice", "portfolio_rebalancing", "portfolio_review"
    ]:
        return {"next": "investment"}
    else:
        return {"next": "unknown"}  # fallback


def build_graph():
    g = StateGraph(GraphState)

    # Instantiate agents
    intents = [
        "set_budget", "update_budget", "get_budgets", "send_money", "check_balance", "portfolio_value", "stock_pnl",
        "portfolio_strategy", "portfolio_advice", "portfolio_rebalancing", "portfolio_review", "portfolio_optimize"
    ]
    intent_agent = IntentAgent(intents=intents)
    budget_agent = BudgetAgent()
    payment_agent = PaymentAgent()
    investment_agent = InvestmentAgent()

    def intent_node(state: GraphState):
        intent, entities, conf = intent_agent.classify(state["input"])
        # For stock_pnl, try to extract stock name from input
        if intent == "stock_pnl":
            stock = None
            for s in DYNAMIC_STOCKS:
                if s in state["input"].lower():
                    stock = s.upper() if s != "infy" else "INFY"
                    break
            entities["stock"] = stock if stock else "RELIANCE"
        if intent == "portfolio_optimize":
            # Try to extract expenses from input
            import re
            match = re.search(r"(\d{3,})", state["input"])
            if match:
                entities["expenses"] = int(match.group(1))
                entities["amount"] = float(match.group(1))
            else:
                entities["expenses"] = 0
                entities["amount"] = None
        return {
            "intent": intent,
            "params": entities,
        }

    def unknown_node(state):
        return {"result": "Sorry, I didn't understand your request."}

    # --- Nodes ---
    g.add_node("intent", intent_node)
    g.add_node("budget", budget_agent.run)
    g.add_node("payment", payment_agent.run)
    g.add_node("investment", investment_agent.run)
    g.add_node("unknown", unknown_node)

    # --- Router node ---
    g.add_node("route", route_intent)

    # --- Wiring ---
    g.set_entry_point("intent")
    g.add_edge("intent", "route")
    g.add_conditional_edges(
        "route",
        lambda state: state["next"],
        {
            "budget": "budget",
            "payment": "payment",
            "investment": "investment",
            "unknown": "unknown",
        }
    )

    return g.compile()
