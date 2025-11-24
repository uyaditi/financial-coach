from resources.agents.intent_agent import IntentAgent
from resources.agents.memory_agent import MemoryAgent
from resources.agents.budget_agent import set_budget
from resources.agents.payment_agent import execute_payment_tool
from resources.agents.voice_agent import VoiceAgent

from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
# from langchain.agents import create_tool_calling_agent

from resources import config


# ---------------------------------------
# 1. Create real Groq LLM
# ---------------------------------------
llm = ChatGroq(
    model="llama3-70b-8192",
    api_key=config.GROQ_API_KEY
)


# ---------------------------------------
# 2. Build Intent Agent
# ---------------------------------------
intent_agent = IntentAgent(model="llama3-70b-8192", use_llm=True)


# ---------------------------------------
# 3. Memory Agent
# ---------------------------------------
memory = MemoryAgent()


# ---------------------------------------
# 4. Voice Agent (callback-style)
# ---------------------------------------
def on_user_text(text: str):
    print("\n[USER]:", text)

    # Step A — Intent detection
    intent_result = intent_agent.classify(text)
    print("[IntentAgent]:", intent_result)

    intent, params, confidence = intent_result

    # Step B — Execute task based on intent
    if intent == "set_budget":
        result = set_budget(params["amount"])
        print("[BudgetAgent]:", result)

        # Save memory
        if "amount" in params:
            memory.set("budget", params["amount"])

    elif intent == "send_money":
        result = execute_payment_tool.invoke(params)
        print("[PaymentAgent]:", result)

    else:
        print("[System]: Unknown intent")


voice = VoiceAgent(on_text_callback=on_user_text)


# ---------------------------------------
# 5. Run simple REPL (text loop)
# ---------------------------------------
if __name__ == "__main__":
    print("Financial Agent Test (text input). Type 'quit' to exit.\n")

    while True:
        user = input("You: ")
        if user.lower() == "quit":
            break
        voice.listen_text(user)
