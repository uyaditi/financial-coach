from fastapi import FastAPI
from routes.budget_routes import router as budget_routes

app = FastAPI()

app.include_router(budget_routes)


if __name__  == "__main__":
    import uvicorn 
    uvicorn.run(app, host="0.0.0.0", port=8000)