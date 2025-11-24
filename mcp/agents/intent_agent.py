import os
import re
from typing import Optional, Dict, Tuple, List
from pydantic import BaseModel, Field
from dotenv import load_dotenv

from langchain_groq import ChatGroq
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import PydanticOutputParser

load_dotenv()


class IntentSchema(BaseModel):
    intent: str
    amount: Optional[float] = None
    payee: Optional[str] = None
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
                """ \no_think You are an intent extractor for a financial assistant. """
                "Identify the user's intent and extract amount (if any) and payee (if any).\n\n"
                "VERY IMPORTANT: Return ONLY valid JSON. No explanation. No thinking. No <think> blocks.\n"
                 "DO NOT include internal reasoning in the output.\n\n"
                "Utterance: {text}\n\n"
                "Available intents: {intents_list}\n\n"
                "Return only valid JSON following this schema:\n\n"
                "{parser_schema}\n\n"
                "If intent is unclear, return intent='unknown'."
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
            response = self.llm.invoke([
                {
                "role": "system",
                "content": "You are a helpful assistant.",
                },
                { "role": "user", "content": prompt_text },
            ])
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

            return (
                parsed.intent,
                {"amount": parsed.amount, "payee": parsed.payee},
                float(parsed.confidence) if parsed.confidence else 0.85
            )

        except Exception as e:
            print("[DEBUG] LLM FAILED!!!!!!!!!")
            print("[DEBUG] e:", e)
            # fallback if LLM fails
            return "unknown", {"amount": None, "payee": None}, 0.0
