from langgraph.graph import StateGraph
from langgraph.graph.message import add_messages

from mcp.agents.budget_agent import BudgetAgent
from mcp.agents.payment_agent import PaymentAgent
from mcp.agents.intent_agent import IntentAgent
from typing import TypedDict, Any

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

    if intent == "set_budget":
        return {"next": "budget"}
    elif intent == "send_money":
        return {"next": "payment"}
    else:
        return {"next": "unknown"}  # fallback


def build_graph():
    g = StateGraph(GraphState)

    # Instantiate agents
    intents = ["set_budget", "send_money", "check_balance"]
    intent_agent = IntentAgent(intents=intents)
    budget_agent = BudgetAgent()
    payment_agent = PaymentAgent()


    def intent_node(state: GraphState):
        intent, entities, conf = intent_agent.classify(state["input"])
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
        "unknown": "unknown",
    }
)

    return g.compile()
