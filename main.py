from fastapi import FastAPI
from pydantic import BaseModel

# ---- Import DB + Models ----
from config.database import Base, engine
import models

# ---- Import Workflow Graph Builder ----
from graph.graph_builder import build_graph

# ---- Import Routers ----
from routes.budget_routes import router as budget_routes
from routes.investment_routes import router as investment_routes
from routes.transaction_routes import router as transaction_routes


app = FastAPI(
    title="Financial AI Agent API",
    description="HTTP endpoint for the Financial AI conversational agent",
    version="1.0.0"
)

app.include_router(budget_routes)
app.include_router(investment_routes)
app.include_router(transaction_routes)

Base.metadata.create_all(bind=engine)

workflow = build_graph()

class ChatRequest(BaseModel):
    message: str

@app.post("/chat")
async def chat_agent(request: ChatRequest):
    """
    Send a message to the Financial AI Agent and get a response.
    """
    result = workflow.invoke({"input": request.message})
    return {"response": result}


@app.get("/")
async def root():
    return {"message": "Financial AI Agent API is running. Use POST /chat to interact."}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
