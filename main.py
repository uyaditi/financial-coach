import threading
import time
import uuid
from typing import Dict, Any, List
from agents.base_agent import BaseAgent
from agents.payment_agent import PaymentAgent
from agents.budget_agent import BudgetAgent
from agents.voice_agent import VoiceAgent
from agents.intent_agent import IntentAgent
from agents.memory_agent import MemoryAgent
from orchestration.coordinator import Coordinator
from orchestration.message_bus import MessageBus

# ------------------------
# Simple user input loop to accept confirmations
# ------------------------
def user_input_loop(bus, voice_agent):
    while True:
        txt = input("YOU (type as voice): ").strip()
        if not txt:
            continue
        # simple yes/no handling to feed confirmations
        l = txt.lower()
        if l in ('yes', 'y'):
            # send confirm_yes to Coordinator
            bus.send({
                "id": str(uuid.uuid4()),
                "sender": "User",
                "receiver": "Coordinator",
                "type": "RESPONSE",
                "intent": "confirm_yes",
                "parameters": {}
            })
        elif l in ('no', 'n'):
            bus.send({
                "id": str(uuid.uuid4()),
                "sender": "User",
                "receiver": "VoiceAgent",
                "type": "RESPONSE",
                "intent": "speak_response",
                "parameters": {"text": "Okay, cancelled."}
            })
        else:
            voice_agent.listen_text(txt)

# ------------------------
# Scheduler
# ------------------------
def start_scheduler(agents: List[BaseAgent], interval_seconds=30):
    def loop():
        while True:
            for a in agents:
                if hasattr(a, 'check_state'):
                    try:
                        a.check_state()
                    except Exception as e:
                        print("Scheduler agent error:", e)
            time.sleep(interval_seconds)
    t = threading.Thread(target=loop, daemon=True)
    t.start()

# ------------------------
# Main bootstrap
# ------------------------
def main():
    bus = MessageBus()
    bus.start_loop()

    # define simple intents
    intents = [
        {"intent": "set_budget", "examples": ["set a budget", "set budget to 40000", "i want to save"]},
        {"intent": "send_money", "examples": ["send money", "transfer 300 to Priya"]},
        {"intent": "check_balance", "examples": ["what's my balance", "show my balance"]}
    ]

    # Agents
    voice = VoiceAgent("VoiceAgent", bus)
    intent = IntentAgent("IntentAgent", bus, intents)
    memory = MemoryAgent("MemoryAgent", bus)
    coordinator = Coordinator("Coordinator", bus)
    budget = BudgetAgent("BudgetAgent", bus)
    payment = PaymentAgent("PaymentAgent", bus)

    # start scheduler to call check_state on agents periodically
    start_scheduler([budget], interval_seconds=40)

    # user input loop
    print("Agentic MCP ready. Type commands (e.g., 'set budget to 40000', 'send 300 to Priya'). Type 'yes' to confirm actions.")
    user_input_loop(bus, voice)


if __name__ == "__main__":
    main()
