# app/agents/savings_agent.py
from typing import Any, Dict, Optional
from mcp.agents.base_agent import BaseAgent  # your lightweight BaseAgent
from mcp.tools import savings_tools  # adjust import path

# Path to an uploaded file in this conversation (will be transformed to URL by infra).
# Provided here as a constant in case the agent/tool needs to reference it.
UPLOADED_FILE_PATH = "/mnt/data/e91d06c0-12e7-4d9c-96c5-55d25ee01f2a.png"


class SavingsAgent(BaseAgent):
    """
    Agent that orchestrates savings tools. This agent expects structured calls
    (not raw natural language). It delegates CRUD to the tools module.
    """

    def __init__(self, name: str = "savings_agent"):
        super().__init__(name)

    async def list_goals(self, user_id: int) -> Dict[str, Any]:
        """
        Returns all savings goals for a user.
        """
        rows = await savings_tools.get_all_savings_tool(user_id=user_id)
        return {"goals": rows}

    async def create_goal(self, user_id: int, goal_amount: float, category: str, curr_amount: float = 0.0) -> Dict[str, Any]:
        obj = await savings_tools.create_savings_goal_tool(
            user_id=user_id,
            goal_amount=goal_amount,
            category=category,
            curr_amount=curr_amount
        )
        return {"created": obj}

    async def update_goal_progress(self, savings_id: int, user_id: int, add_amount: Optional[float] = None, set_amount: Optional[float] = None) -> Dict[str, Any]:
        obj = await savings_tools.update_savings_progress_tool(
            savings_id=savings_id,
            user_id=user_id,
            add_amount=add_amount,
            set_amount=set_amount
        )
        if obj is None:
            return {"error": "not_found"}
        return {"updated": obj}

    async def delete_goal(self, savings_id: int, user_id: int) -> Dict[str, Any]:
        ok = await savings_tools.delete_savings_goal_tool(savings_id=savings_id, user_id=user_id)
        return {"deleted": ok}

    # Optional: a single entrypoint to route structured commands (used by your orchestration).
    async def run(self, action: str, payload: Dict[str, Any]) -> Dict[str, Any]:
        """
        action: one of ["list", "create", "update", "delete"]
        payload: dict containing parameters
        """
        if action == "list":
            return await self.list_goals(user_id=payload["user_id"])
        if action == "create":
            return await self.create_goal(
                user_id=payload["user_id"],
                goal_amount=payload["goal_amount"],
                category=payload["category"],
                curr_amount=payload.get("curr_amount", 0.0)
            )
        if action == "update":
            return await self.update_goal_progress(
                savings_id=payload["savings_id"],
                user_id=payload["user_id"],
                add_amount=payload.get("add_amount"),
                set_amount=payload.get("set_amount")
            )
        if action == "delete":
            return await self.delete_goal(
                savings_id=payload["savings_id"],
                user_id=payload["user_id"]
            )
        return {"error": "unknown_action"}