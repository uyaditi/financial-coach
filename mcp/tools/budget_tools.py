# from datetime import datetime
# from services.budget_services import (
#     create_budget,
#     get_budgets,
#     update_budget_limit
# )
# from langchain_groq import ChatGroq
# import os
# from dotenv import load_dotenv
# load_dotenv()

# API_KEY = os.getenv("GROQ_API_KEY")
# MODEL = os.getenv("MODEL_NAME")

# # Initialize LLM (global so it's reused)
# llm = ChatGroq(
#     api_key= API_KEY,
#     model_name = MODEL,
#     temperature=0.1, 
# )

# def summarize(text: str) -> str:
#     """
#     \no_think Converts raw system message into a friendly, natural, user-facing message.
#     """
#     prompt = f"""
#     Rewrite the following message into a friendly financial assistant response.
#     Do NOT include explanations or extra text. USE INR CURRENCY SYMBOL.

#     Message:
#     {text}

#     Return only the rewritten human-friendly sentence.
#     """

#     response = llm.invoke(prompt)
#     return response.content.strip()

# def create_budget_tool(user_id: int, category: str, max_limit: float, time_period: str = None) -> str:
#     if not time_period:
#         time_period = datetime.now().strftime("%Y-%m")

#     result = create_budget(
#         user_id=user_id,
#         category=category,
#         max_limit=max_limit,
#         time_period=time_period
#     )

#     if isinstance(result, dict) and result.get("status") == "error":
#         return summarize(f"Failed to create budget: {result['message']}")

#     raw = f"Created a budget for {category} with a limit of {max_limit} for {time_period}."
#     return summarize(raw)


# def get_budgets_tool(user_id: int) -> str:
#     budgets = get_budgets(user_id)

#     if not budgets:
#         return summarize("User has no budgets set.")

#     items = "; ".join([f"{b['category']} → {b['max_limit']} ({b['time_period']})" for b in budgets])
#     raw = f"Budgets: {items}"

#     return summarize(raw)


# def update_budget_tool(user_id: int, category: str, amount: float, time_period: str = None) -> str:
#     if not time_period:
#         time_period = datetime.now().strftime("%Y-%m")

#     result = update_budget_limit(
#         user_id=user_id,
#         category=category,
#         amount=amount,
#         time_period=time_period
#     )

#     if isinstance(result, dict) and result.get("status") == "error":
#         return summarize(f"Failed to update budget: {result['message']}")

#     raw = f"Updated budget for {category} to {amount} for {time_period}."
#     return summarize(raw)


from datetime import datetime
from services.budget_services import (
    create_budget,
    get_budgets,
    update_budget_limit
)
import os
from dotenv import load_dotenv

import google.generativeai as genai

load_dotenv()

# Load Gemini API key + model
GEMINI_KEY = os.getenv("GEMINI_API_KEY")
MODEL = os.getenv("GEMINI_MODEL", "gemini-pro")     

# Configure Gemini globally
genai.configure(api_key=GEMINI_KEY)

# Create a model instance
model = genai.GenerativeModel(MODEL)


def summarize(text: str) -> str:
    """
    Uses Gemini to rewrite tool output into a friendly AI response.
    """

    prompt = f"""
    Rewrite the following message into a friendly financial assistant response.
    Always use the INR currency symbol (₹).
    Do NOT add explanations, assumptions, or extra sentences.

    Message:
    {text}

    Return only the rewritten final sentence.
    """

    response = model.generate_content(
        prompt,
        generation_config={"temperature": 0.1}
    )

    return response.text.strip()


def create_budget_tool(user_id: int, category: str, max_limit: float, time_period: str = None) -> str:
    if not time_period:
        time_period = datetime.now().strftime("%Y-%m")

    result = create_budget(
        user_id=user_id,
        category=category,
        max_limit=max_limit,
        time_period=time_period
    )

    if isinstance(result, dict) and result.get("status") == "error":
        return summarize(f"Error creating budget: {result['message']}")

    raw = f"Created a budget for {category} with a limit of {max_limit} for {time_period}."
    return summarize(raw)


def get_budgets_tool(user_id: int) -> str:
    budgets = get_budgets(user_id)

    if not budgets:
        return summarize("User has no budgets set.")

    items = "; ".join(
        [f"{b['category']} → {b['max_limit']} ({b['time_period']})" for b in budgets]
    )
    raw = f"Budgets: {items}"

    return summarize(raw)


def update_budget_tool(user_id: int, category: str, amount: float, time_period: str = None) -> str:
    if not time_period:
        time_period = datetime.now().strftime("%Y-%m")

    result = update_budget_limit(
        user_id=user_id,
        category=category,
        amount=amount,
        time_period=time_period
    )

    if isinstance(result, dict) and result.get("status") == "error":
        return summarize(f"Error updating budget: {result['message']}")

    raw = f"Updated budget for {category} to {amount} for {time_period}."
    return summarize(raw)
