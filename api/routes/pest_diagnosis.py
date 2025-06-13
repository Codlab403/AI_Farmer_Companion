from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, HttpUrl
from typing import Optional

from fastapi import Depends
from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/pest-diagnosis",
    tags=["Pest Diagnosis"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

class PestDiagnosisRequest(BaseModel):
    image_url: HttpUrl
    crop_type: Optional[str] = None
    region: Optional[str] = None
    is_offline: bool = False

class PestDiagnosisResponse(BaseModel):
    disease_pest_name: str
    treatment_advice: str
    is_urgent: bool
    confidence_score: Optional[float] = None
    offline_fallback_used: bool = False

import random

def mock_model_inference(image_url: str, crop_type: str = None, offline: bool = False):
    """
    Simulates a pest/disease diagnosis using a mock (fake) ONNX/TFLite model.
    Replace this with real model inference logic later.
    """
    # Example mock results
    pests = [
        ("Corn Leaf Aphid", "Apply recommended insecticide. Monitor for natural enemies.", True, 0.85),
        ("Maize Streak Virus", "Remove affected plants. Use resistant varieties.", True, 0.78),
        ("Armyworm", "Handpick and destroy larvae. Use biopesticides if needed.", False, 0.65),
        ("Healthy", "No visible pest or disease detected.", False, 0.99)
    ]
    result = random.choice(pests)
    # Optionally, bias result based on crop_type or offline
    return {
        "disease_pest_name": f"{result[0]}{' (Offline)' if offline else ''}",
        "treatment_advice": result[1],
        "is_urgent": result[2],
        "confidence_score": result[3],
        "offline_fallback_used": offline
    }

@router.post("/diagnose", response_model=PestDiagnosisResponse, summary="Diagnose pest or disease from image")
async def diagnose_pest_from_image(request: PestDiagnosisRequest):
    """
    Analyzes an image (via URL) to identify crop diseases or pests.

    - **image_url**: URL of the image to be analyzed.
    - **crop_type**: Optional. The type of crop in the image.
    - **region**: Optional. The region where the crop is grown.
    - **is_offline**: Indicates if the request is made in offline mode.
    """
    # TODO: Download/process image here if needed for real model
    # image_data = await download_image(request.image_url)

    # Use mock model inference for both online and offline for now
    result = mock_model_inference(request.image_url, request.crop_type, request.is_offline)
    return PestDiagnosisResponse(**result)

# Helper function placeholder (would be in a different module, e.g., utils.py)
# async def download_image(url: HttpUrl):
#     # In a real app, use httpx or requests to download the image
#     # Handle errors, timeouts, etc.
#     # Return image data (e.g., bytes)
#     pass
