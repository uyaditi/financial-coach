from langchain_groq import ChatGroq
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import PydanticOutputParser
from pydantic import BaseModel, Field
from dotenv import load_dotenv
import os

load_dotenv()

class ToneEmotionSchema(BaseModel):
    emotion: str = Field(..., description="Primary emotion of the user query.")
    tone: str = Field(..., description="Tone/Style of the query (e.g., urgent, polite, casual)")


class BaseAgent:
    def __init__(self, name: str):
        self.name = name

        self.model_name = os.getenv("MODEL_NAME")
        self.groq_api_key = os.getenv("GROQ_API_KEY")

        if self.model_name and self.groq_api_key:
            self.llm = ChatGroq(
                model_name=self.model_name, 
                api_key=self.groq_api_key, 
                temperature=0.0
            )
            self._tone_parser = PydanticOutputParser(pydantic_object=ToneEmotionSchema)

            self._tone_prompt = PromptTemplate(
                input_variables=["text", "schema"], 
                template=(
                    "You are an expert emotion and tone analyzer.\n"
                    "Given the user query, return STRICT JSON with:\n"
                    "- emotion\n"
                    "- tone\n"
                    "- synonyms (related key terms)\n\n"
                    "User Query: {text}\n\n"
                    "Schema:\n{schema}"
                )
            )
        else:
            self.llm = None
            self._tone_parser = None
            self._tone_prompt = None

    def detect_tone_and_emotion(self, text: str) -> dict:
        """
        LLM-based tone and emotion detection.
        Returns: {'emotion': str, 'tone': str, 'synonyms': list[str]}
        """
        if not self.llm:
            return {
                "emotion": "neutral",
                "tone": "neutral",
                "synonyms": [],
            }

        schema = self._tone_parser.get_format_instructions()
        prompt = self._tone_prompt.format(text=text, schema=schema)
        
        try:
        # llm_resp = self.llm.invoke([{"role": "user", "content": prompt}])
            llm_resp = self.llm.invoke(prompt)
            # raw_text = raw.generations[0][0].text
            raw_text = llm_resp.content
            parsed = self._tone_parser.parse(raw_text)
            return parsed.dict()
        # try: 
        #     parsed = self._tone_parser.parse(raw_text)
        #     return parsed.dict()
        except Exception as e:
            return {
                "emotion": "neutral",
                "tone": "neutral",
                "synonyms": [],
            }        


    def run(self, *args, **kwargs):
        """
        Default agent behavior. Should be overridden by subclasses.
        In LangGraph, this method is what the graph node executes.
        """
        raise NotImplementedError(f"{self.name}.run() not implemented")

    def __repr__(self):
        return f"<Agent: {self.name}>"