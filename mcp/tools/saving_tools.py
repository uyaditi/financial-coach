# app/tools/savings_tools.py
from typing import List, Optional
import asyncio

# Import your dependency injection utilities to get an AsyncSession.
# For example, in FastAPI you'd have a dependency that yields AsyncSession.
from sqlalchemy.ext.asyncio import AsyncSession

from app.services.savings_service import SavingsService
from app.models import Savings as SavingsModel  # adjust path
from app.core.database import get_async_session  # adapt to your project

savings_service = SavingsService()

# Note: adapt these wrappers to the way LangGraph expects tools to be defined.
# Below are simple async callables that call service functions.

async def get_all_savings_tool(user_id: int, db: Optional[AsyncSession] = None) -> List[dict]:
    """
    Returns list of savings as serializable dicts.
    If db is None, this function will create a session via get_async_session().
    """
    close_after = False
    if db is None:
        db = await get_async_session()
        close_after = True

    try:
        rows = await savings_service.get_all_savings(db, user_id)
        # convert to dicts (manual or via pydantic)
        out = [
            {
                "id": r.id,
                "user_id": r.user_id,
                "goal_amount": float(r.goal_amount),
                "category": r.category,
                "curr_amount": float(r.curr_amount)
            } for r in rows
        ]
        return out
    finally:
        if close_after:
            await db.close()

async def create_savings_goal_tool(
    user_id: int,
    goal_amount: float,
    category: str,
    curr_amount: float = 0.0,
    db: Optional[AsyncSession] = None
) -> dict:
    close_after = False
    if db is None:
        db = await get_async_session()
        close_after = True
    try:
        obj = await savings_service.create_savings_goal(db, user_id, goal_amount, category, curr_amount)
        return {
            "id": obj.id,
            "user_id": obj.user_id,
            "goal_amount": float(obj.goal_amount),
            "category": obj.category,
            "curr_amount": float(obj.curr_amount)
        }
    finally:
        if close_after:
            await db.close()

async def update_savings_progress_tool(
    savings_id: int,
    user_id: int,
    add_amount: Optional[float] = None,
    set_amount: Optional[float] = None,
    db: Optional[AsyncSession] = None
) -> Optional[dict]:
    close_after = False
    if db is None:
        db = await get_async_session()
        close_after = True
    try:
        obj = await savings_service.update_savings_progress(db, savings_id, user_id, add_amount, set_amount)
        if obj is None:
            return None
        return {
            "id": obj.id,
            "user_id": obj.user_id,
            "goal_amount": float(obj.goal_amount),
            "category": obj.category,
            "curr_amount": float(obj.curr_amount)
        }
    finally:
        if close_after:
            await db.close()

async def delete_savings_goal_tool(savings_id: int, user_id: int, db: Optional[AsyncSession] = None) -> bool:
    close_after = False
    if db is None:
        db = await get_async_session()
        close_after = True
    try:
        ok = await savings_service.delete_savings_goal(db, savings_id, user_id)
        return ok
    finally:
        if close_after:
            await db.close()

# Helper to register with LangGraph or other tool systems:
# e.g.
# tools = {
#    "get_all_savings": get_all_savings_tool,
#    "create_savings_goal": create_savings_goal_tool,
#    ...
# }