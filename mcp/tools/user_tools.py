from langgraph.prebuilt import Tool
from app.config.database import SessionLocal
from app.models.users import User


def get_user_fn(user_id: int):
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.id == user_id).first()
        if not user:
            return {"error": "User not found"}

        return {
            "id": user.id,
            "email": user.email,
            "name": user.name,
        }
    finally:
        db.close()


get_user_tool = Tool(
    name="get_user",
    description="Fetch basic details for a user.",
    func=get_user_fn,
)
