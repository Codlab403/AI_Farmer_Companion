import os
from pathlib import Path
from dotenv import load_dotenv

# Construct the path to the .env file in the project root
env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(dotenv_path=env_path, override=True)

# TODO: Implement Custom Crop-Disease Classifier Training (Optional)
# This is a significant task involving:
# 1. Data Collection: Gather a large dataset of crop images with labeled diseases/pests.
# 2. Data Preprocessing: Clean, augment, and prepare the image data for training.
# 3. Model Selection: Choose an appropriate model architecture (e.g., ResNet, EfficientNet) or fine-tune a pre-trained model.
# 4. Model Training: Train the model on the prepared dataset using a deep learning framework (e.g., TensorFlow, PyTorch).
# 5. Model Evaluation: Evaluate the model's performance on a separate test set.
# 6. Model Conversion: Convert the trained model to a format suitable for deployment (e.g., TFLite for mobile, ONNX for backend).
# 7. Integration: Integrate the trained model into the backend's pest diagnosis endpoint (`api/routes/data.py`) or deploy it as a separate service.
# 8. Ongoing Maintenance: Periodically retrain the model with new data to improve accuracy.
# This task requires expertise in machine learning and access to relevant datasets and computing resources.

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
from .routes import chat, data, weather, voice # Import the new voice router

# Include routers
# chat.router already has prefix "/chat", so mounting at "/api/v1" yields paths like /api/v1/chat/ask
app.include_router(chat.router, prefix="/api/v1", tags=["Chat"])
app.include_router(data.router, prefix="/api/v1/data", tags=["Application Data"])
app.include_router(weather.router, prefix="/api/v1", tags=["Weather"])
app.include_router(voice.router, prefix="/api/v1", tags=["Voice"]) # Include the new voice router

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
