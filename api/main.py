import os
from pathlib import Path
from dotenv import load_dotenv

# Construct the path to the .env file in the project root
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path, override=True)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Initialize FastAPI app
app = FastAPI(
    title="AI Farmer's Companion API",
    description="API for the AI Farmer's Companion application, providing agricultural support.",
    version="0.1.0"
)

# Add CORS middleware to allow requests from the Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # In production, restrict this to your app's domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", summary="Health Check", tags=["General"])
async def health_check():
    """
    Endpoint to check the health of the API.
    Returns a simple status message.
    """
    return {"status": "API is healthy"}

# Import routers from the routes module
from .routes import chat, data, weather

# Include routers
# chat.router already has prefix "/chat", so mounting at "/api/v1" yields paths like /api/v1/chat/ask
app.include_router(chat.router, prefix="/api/v1", tags=["Chat"])
app.include_router(data.router, prefix="/api/v1/data", tags=["Application Data"])
app.include_router(weather.router, prefix="/api/v1", tags=["Weather"])

# We will add other routers for different features later.
# For example:
# from .routes import some_other_feature
# app.include_router(some_other_feature.router)

from .core.security import get_current_user_id
from fastapi import Depends

@app.get("/protected", tags=["General"])
async def protected_route(user_id: str = Depends(get_current_user_id)):
    """
    Example protected route. Requires a valid Supabase Auth JWT in the Authorization header.
    """
    return {"user_id": user_id, "message": "You are authenticated!"}

if __name__ == "__main__":
    # This is for local development running the Uvicorn server directly.
    # For production, you'd typically use a process manager like Gunicorn with Uvicorn workers.
    uvicorn.run(app, host="0.0.0.0", port=8000)
