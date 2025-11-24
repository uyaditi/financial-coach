from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.exc import NoResultFound

from app.config.database import Savings  # adjust import path if needed
from app.models.savings import Savings as SavingsModel


class SavingsService: 
    """
    Async CRUD operations on Savings model. 
    All methods accept an AsyncSession provided by the caller (e.g. dependency injection).
    """

    async def get_all_savings(self, db: AsyncSession, user_id: Optional[int] = None) -> Optional[SavingsModel]:
        stmt = select(Savings).where(SavingsModel.user_id == user_id)
        result  = db.execute(stmt)
        rows = result.scalars().all()
        return rows 
    
    async def get_savings_by_id(self, db: AsyncSession, savings_id: int, user_id: Optional[int] = None) -> Optional[SavingsModel]:
        stmt = select(SavingsModel).where(SavingsModel.id == savings_id)
        if user_id is not None:
            stmt = stmt.where(SavingsModel.user_id == user_id)
        result = await db.execute(stmt)
        row = result.scalar_one_or_none()
        return row
    
    async def create_savings_goal(
        self,
        db: AsyncSession,
        user_id: int,
        goal_amount: float,
        category: str,
        curr_amount: float = 0.0
    ) -> SavingsModel:
        obj = SavingsModel(
            user_id=user_id,
            goal_amount=goal_amount,
            category=category,
            curr_amount=curr_amount
        )
        db.add(obj)
        await db.flush()  
        await db.commit()
        await db.refresh(obj)
        return obj
    
    async def update_savings_progress(
        self,
        db: AsyncSession,
        savings_id: int,
        user_id: int,
        add_amount: Optional[float] = None,
        set_amount: Optional[float] = None
    ) -> Optional[SavingsModel]:
        """
        If add_amount is provided, increment curr_amount by that.
        If set_amount is provided, set curr_amount to that (overrides add_amount).
        Returns the updated model or None if not found.
        """
        stmt = select(SavingsModel).where(SavingsModel.id == savings_id, SavingsModel.user_id == user_id)
        result = await db.execute(stmt)
        obj = result.scalar_one_or_none()
        if obj is None:
            return None

        if set_amount is not None:
            obj.curr_amount = float(set_amount)
        elif add_amount is not None:
            obj.curr_amount = float(obj.curr_amount or 0.0) + float(add_amount)

        db.add(obj)
        await db.commit()
        await db.refresh(obj)
        return obj
    
    async def delete_savings_goal(self, db: AsyncSession, savings_id: int, user_id: int) -> bool:
        stmt = select(SavingsModel).where(SavingsModel.id == savings_id, SavingsModel.user_id == user_id)
        result = await db.execute(stmt)
        obj = result.scalar_one_or_none()
        if obj is None:
            return False
        await db.delete(obj)
        await db.commit()
        return True