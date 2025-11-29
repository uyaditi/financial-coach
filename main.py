from fastapi import FastAPI
from routes.budget_routes import router as budget_routes
from routes.investment_routes import router as investment_routes
from routes.transaction_routes import router as transaction_routes

app = FastAPI()

app.include_router(budget_routes)
app.include_router(investment_routes)
app.include_router(transaction_routes)


if __name__  == "__main__":
    import uvicorn 
    uvicorn.run(app, host="0.0.0.0", port=8000)