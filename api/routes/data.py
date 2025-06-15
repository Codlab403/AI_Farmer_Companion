import os
import io
import json
from fastapi import APIRouter, HTTPException, File, UploadFile
import google.generativeai as genai
from PIL import Image

# Import cached market prices data and loading function
from .market_prices import _market_prices_cache, load_market_prices_data

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
    """Returns market price data from cache."""
    # Use the cached data loaded by the market_prices module
    market_prices = _market_prices_cache

    if not market_prices:
         # Attempt to reload data if cache is empty (e.g., on first request after startup error)
         load_market_prices_data()
         market_prices = _market_prices_cache
         if not market_prices:
              raise HTTPException(status_code=500, detail="Market prices data not available.")

    return market_prices

# Placeholder for caching crop info data (similar to market prices)
_crop_info_cache = None

def load_crop_info_data():
    """Loads crop information data from a JSON file."""
    global _crop_info_cache
    data_path = os.path.join(os.path.dirname(__file__), "..", "data", "crop_info.json") # Assuming crop_info.json exists
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            _crop_info_cache = json.load(f)
        print("DEBUG - Crop info data loaded and cached.")
    except FileNotFoundError:
        print(f"ERROR - Crop info data file not found at {data_path}")
        _crop_info_cache = [] # Initialize as empty list on error
    except json.JSONDecodeError:
        print(f"ERROR - Error decoding crop info data from {data_path}")
        _crop_info_cache = [] # Initialize as empty list on error
    except Exception as e:
        print(f"ERROR - An unexpected error occurred loading crop info: {e}")
        _crop_info_cache = [] # Initialize as empty list on error

# Load data when the module is imported
load_crop_info_data()

@router.get("/crop-info")
async def get_crop_info():
    """Returns crop information from cache (placeholder for real data)."""
    # Use the cached data
    crop_info = _crop_info_cache

    if not crop_info:
         # Attempt to reload data if cache is empty
         load_crop_info_data()
         crop_info = _crop_info_cache
         if not crop_info:
              raise HTTPException(status_code=500, detail="Crop information data not available.")

    return crop_info

@router.post("/pest-diagnose")
async def diagnose_pest(file: UploadFile = File(...)):
    """Receives an image, sends it to Gemini for diagnosis, and returns the result."""
    # TODO: Improve Pest Diagnosis Backend
    # 1. Implement more robust image handling (validation, resizing, format conversion).
    # 2. Refine the prompt for the Gemini model for better diagnosis accuracy and format consistency.
    # 3. Implement more robust parsing of the Gemini response to handle variations in output.
    # 4. Consider integrating with a dedicated, potentially fine-tuned, image classification model instead of or in addition to Gemini.
    # 5. Implement logic to store diagnosis requests and results in the database.
    # 6. Add error handling for cases where the uploaded file is not an image.

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
