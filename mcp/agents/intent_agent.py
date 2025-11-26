import os
import re
from typing import Optional, Dict, Tuple, List
from pydantic import BaseModel, Field
from dotenv import load_dotenv

from langchain_groq import ChatGroq
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import PydanticOutputParser

from datetime import datetime, timedelta
import calendar

load_dotenv()

from datetime import datetime, timedelta
import calendar

def extract_time_period(text: str):
    text = text.lower()
    # explicit month names
    for idx, month in enumerate(calendar.month_name):
        if idx == 0:
            continue
        if month.lower() in text:
            year = datetime.now().year
            return f"{year}-{idx:02d}"

    # implicit
    if "this month" in text:
        return datetime.now().strftime("%Y-%m")
    if "next month" in text:
        next_month = (datetime.now().replace(day=1) + timedelta(days=32))
        return next_month.strftime("%Y-%m")

    return None


class IntentSchema(BaseModel):
    intent: str
    amount: Optional[float] = None
    payee: Optional[str] = None
    category: Optional[str] = None
    confidence: Optional[float] = None


class IntentAgent:
    def __init__(self, intents: Optional[List[Dict]] = None):
        self.intents = intents or []

        self.model_name = os.getenv("MODEL_NAME")
        api_key = os.getenv("GROQ_API_KEY")

        if api_key is None:
            raise ValueError("GROQ_API_KEY is missing in environment variables.")

        self.llm = ChatGroq(
            model_name=self.model_name,
            api_key=api_key,
            temperature=0.0
        )

        self.parser = PydanticOutputParser(pydantic_object=IntentSchema)

        self.prompt = PromptTemplate(
            input_variables=["text", "intents_list", "parser_schema"],
            template=(
                """ 
                \no_think You are an intent extractor for a financial assistant.
                Your job:
                1. Identify the user's intent from: {intents_list} 
                2. Extract amount (if present), 
                3. Extract category (budget or expense categor like food, commute, etcif any), 
                4. Extractpayee (if any for payments).
                5. Detect time period expressions such as:
                - "this month" → current YYYY-MM
                - "next month" → next YYYY-MM
                - explicit month name e.g. "December" → map to YYYY-12

                "VERY IMPORTANT: Return ONLY valid JSON. No explanation. No thinking. No <think> blocks.\n"
                "DO NOT include internal reasoning in the output.\n\n"
                "Utterance: {text}\n\n"
                "Available intents: {intents_list}\n\n"
                "Return only valid JSON following this schema:\n\n"
                "{parser_schema}\n\n"
                "If intent is unclear, return intent='unknown'.
                """
            )
        )

    def classify(self, text: str) -> Tuple[str, Dict, float]:
        # intents_list = ", ".join([it["intent"] for it in self.intents]) if self.intents else "send_money, set_budget, unknown"
        intents_list = ", ".join(self.intents)
        schema_text = self.parser.get_format_instructions()
        # print("[DEBUG] schema_text:", schema_text)

        prompt_text = self.prompt.format(
            text=text,
            intents_list=intents_list,
            parser_schema=schema_text
        )

        # print("[DEBUG] prompt_text:", prompt_text)
        try:
            response = self.llm.invoke([prompt_text])
            out = response.content
            # print("[DEBUG] out:", out)

            import re
            # extract first JSON object
            json_match = re.search(r"\{.*\}", out, re.DOTALL)

            if json_match:
                out = json_match.group(0)
            else:
                raise ValueError("No JSON found in LLM output")
            
            parsed = self.parser.parse(out)
            category = parsed.category or parsed.payee
            time_period = extract_time_period(text)
        
            entities = {
                "amount": parsed.amount,
                "category": category,
                "time_period": time_period
            }

            return (
                parsed.intent,
                entities,
                float(parsed.confidence) if parsed.confidence else 0.85
            )

        except Exception as e:
            print("[DEBUG] LLM FAILED!!!!!!!!!")
            print("[DEBUG] e:", e)
            # fallback if LLM fails
            return "unknown", {"amount": None, "payee": None}, 0.0
