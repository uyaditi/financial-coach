from fastapi import FastAPI
from routes.budget_routes import router as budget_routes

app = FastAPI()

app.include_router(budget_routes)
