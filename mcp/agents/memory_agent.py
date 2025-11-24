from typing import Any, Dict, Optional 

class MemoryAgent: 
    """
    A unified memory layer combining:
    - LangChain conversation memory (history)
    - Custom structured key-value memory
    """
    def __init__(self, llm=None):
        # ConversationSummaryMemory requires an LLM for summarization
        if llm is None:
            # If you want to use summary memory, you need to provide an LLM
            # Alternative: use ConversationBufferMemory instead
            from langchain_classic.memory import ConversationBufferMemory
            self.chat_memory = ConversationBufferMemory(
                memory_key="chat_history",
                return_messages=True
            )
        else:
            from langchain_community.memory import ConversationSummaryMemory
            self.chat_memory = ConversationSummaryMemory(
                llm=llm,
                memory_key="chat_history",
                return_messages=True
            )
        self.kv_memory: Dict[str, Any] = {}
    
    def load_conversation_memory(self):
        return self.chat_memory
    
    def clear_conversation(self):
        self.chat_memory.clear()
    
    def set(self, key: str, value: Any):
        """Save structured memory value."""
        self.kv_memory[key] = value
    
    def get(self, key: str) -> Optional[Any]:
        """Retrieve structured memory value."""
        return self.kv_memory.get(key)
    
    def delete(self, key: str):
        if key in self.kv_memory:
            del self.kv_memory[key]
    
    def clear_kv_memory(self):
        self.kv_memory.clear()
    
    def debug_state(self) -> Dict[str, Any]:
        """Returns full memory state for debugging."""
        return {
            "conversation_memory": str(self.chat_memory.chat_memory.messages),
            "kv_memory": self.kv_memory.copy()
        }