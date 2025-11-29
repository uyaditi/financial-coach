from datetime import datetime
from services.transaction_services import (
    create_expense,
    create_income,
    get_transactions,
    delete_transaction,
    update_transaction
)
import os
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

GEMINI_KEY = os.getenv("GEMINI_API_KEY")
MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")

# Configure Gemini
genai.configure(api_key=GEMINI_KEY)

# Model instance
model = genai.GenerativeModel(MODEL)


def summarize(text: str) -> str:
    """
    Use Gemini to turn raw transaction output into natural English.
    """

    prompt = f"""
    Rewrite the following as a friendly financial assistant response.
    ALWAYS use the INR symbol (₹).
    Do NOT add extra explanation, assumptions, or multiple sentences.

    Message:
    {text}

    Return only ONE clean rewritten sentence.
    """

    response = model.generate_content(
        prompt,
        generation_config={"temperature": 0.1}
    )

    return response.text.strip()


def create_expense_tool(user_id: int, amount: float, category: str, payee: str, raw_description: str, is_recurring: bool) -> str:
    result = create_expense(
        user_id=user_id,
        amount=amount,
        category=category,
        payee=payee,
        raw_description=raw_description,
        is_recurring=is_recurring
    )

    if result.get("status") == "error":
        return summarize(f"Error creating expense: {result['message']}")

    tx_id = result["transaction_id"]
    raw = f"Created an expense of ₹{amount} in category {category}. Transaction ID: {tx_id}."
    return summarize(raw)


def create_income_tool(user_id: int, amount: float, category: str, payee: str, raw_description: str, is_recurring: bool) -> str:
    result = create_income(
        user_id=user_id,
        amount=amount,
        category=category,
        payee=payee,
        raw_description=raw_description,
        is_recurring=is_recurring
    )

    if result.get("status") == "error":
        return summarize(f"Error creating income: {result['message']}")

    tx_id = result["transaction_id"]
    raw = f"Recorded income of ₹{amount} in category {category}. Transaction ID: {tx_id}."
    return summarize(raw)


def get_transactions_tool(user_id: int, type: str = None, category: str = None) -> str:
    result = get_transactions(type=type, category=category)

    if result.get("status") == "error":
        return summarize(f"Error fetching transactions: {result['message']}")

    txns = result.get("transaction", [])

    if not txns:
        return summarize("No transactions found.")

    raw = "; ".join([
        f"{t['type']} of ₹{t['amount']} in {t['category']} on {t['timestamp']}"
        for t in txns
    ])

    return summarize(f"Transactions: {raw}")


def update_transaction_tool(category: str, amount: float, date_str: str, type: str = "expense") -> str:
    result = update_transaction(
        category=category,
        amount=amount,
        date_str=date_str,
        type=type
    )

    if result.get("status") == "error":
        return summarize(f"Error updating transaction: {result['message']}")

    tx_id = result["transaction_id"]
    raw = f"Updated the {type} in category {category} on {date_str} to ₹{amount}. Transaction ID: {tx_id}."
    return summarize(raw)


def delete_transaction_tool(category: str, date_str: str, type: str = "expense") -> str:
    result = delete_transaction(
        category=category,
        date_str=date_str,
        type=type
    )

    if result.get("status") == "error":
        return summarize(f"Error deleting transaction: {result['message']}")

    tx_id = result["transaction_id"]
    raw = f"Deleted the {type} in category {category} on {date_str}. Transaction ID: {tx_id}."
    return summarize(raw)
