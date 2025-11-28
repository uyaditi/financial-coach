from fastapi import APIRouter
from services.portfolio import get_stock_investments

router = APIRouter(prefix="/investments", tags=["Investments"])

@router.get("/", response_model=dict)
def fetch_investments(user_id: int = 1):
    """
    Fetch all investments for the given user.
    """
    return get_stock_investments(user_id)