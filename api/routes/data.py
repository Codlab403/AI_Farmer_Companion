import os
import io
import json
from fastapi import APIRouter, HTTPException, File, UploadFile
import google.generativeai as genai
from PIL import Image

router = APIRouter()

# Configure the Gemini client at the module level
try:
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("Warning: GEMINI_API_KEY not found. Pest diagnosis will fail.")
    else:
        genai.configure(api_key=api_key)
except Exception as e:
    print(f"Error configuring Gemini: {e}")

@router.get("/market-prices")
async def get_market_prices():
    """Returns mock market price data."""
    return [
        {'crop': 'Wheat', 'price': '1,500 ETB/quintal'},
        {'crop': 'Teff', 'price': '7,000 ETB/quintal'},
        {'crop': 'Maize', 'price': '1,200 ETB/quintal'},
        {'crop': 'Coffee', 'price': '9,500 ETB/quintal'},
    ]

@router.get("/crop-info")
async def get_crop_info():
    """Returns mock crop information."""
    return [
        {'name': 'Teff', 'description': 'A staple grain in Ethiopia, resistant to many pests.'},
        {'name': 'Maize', 'description': 'A major food crop, grown in various altitudes.'},
        {'name': 'Coffee', 'description': 'Ethiopia\'s most famous export, known for its rich flavor.'},
        {'name': 'Wheat', 'description': 'Widely cultivated for bread and other baked goods.'},
    ]

@router.post("/pest-diagnose")
async def diagnose_pest(file: UploadFile = File(...)):
    """Receives an image, sends it to Gemini for diagnosis, and returns the result."""
    if not genai.API_KEY:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY is not configured on the server.")

    try:
        model = genai.GenerativeModel('gemini-1.5-flash')
        contents = await file.read()
        img = Image.open(io.BytesIO(contents))

        prompt = """
        You are an expert agriculturalist specializing in Ethiopian crops.
        Analyze the following image of a plant.
        Identify any visible diseases or pests.
        Provide a diagnosis, a confidence score (from 0 to 1), and a clear, actionable recommendation for an Ethiopian farmer.
        Format the response as a JSON object with three keys: "diagnosis", "confidence", and "recommendation".
        If the image is not a plant or the quality is too poor for diagnosis, return a JSON object with an "error" key.
        Example valid response: {"diagnosis": "Corn Rust", "confidence": 0.92, "recommendation": "Apply a fungicide immediately. Ensure proper spacing between plants to improve air circulation."}
        Example error response: {"error": "Image is unclear or does not contain a plant."}
        """

        response = model.generate_content([prompt, img])
        
        # Clean up potential markdown formatting from the response
        cleaned_text = response.text.strip().replace("```json", "").replace("```", "").strip()
        diagnosis_json = json.loads(cleaned_text)

        print(f"--- Gemini Diagnosis for {file.filename}: {diagnosis_json} ---")
        return diagnosis_json

    except Exception as e:
        print(f"Error during pest diagnosis: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred processing the image: {str(e)}")
