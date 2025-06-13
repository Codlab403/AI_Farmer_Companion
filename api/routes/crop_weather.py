from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import Optional
from datetime import date

from fastapi import Depends
from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/crop-weather",
    tags=["Crop & Weather"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

class CropWeatherParams(BaseModel):
    latitude: float
    longitude: float
    crop_type: Optional[str] = None
    request_date: date = date.today()
    is_offline: bool = False

import requests

@router.get("/advisory", summary="Get crop and weather advisory")
async def get_crop_weather_advisory(
    latitude: float = Query(..., description="Latitude of the location"),
    longitude: float = Query(..., description="Longitude of the location"),
    crop_type: Optional[str] = Query(None, description="Specific crop type for advisory"),
    request_date: date = Query(date.today(), description="Date for which advisory is requested (YYYY-MM-DD)"),
    is_offline: bool = Query(False, description="Indicates if the request is made in offline mode")
):
    """
    Provides crop-specific advice and weather forecasts using Open-Meteo (when online).

    - **latitude**: Latitude of the farm/location.
    - **longitude**: Longitude of the farm/location.
    - **crop_type**: Optional. The specific crop the farmer is interested in (e.g., 'maize', 'teff').
    - **request_date**: The date for the advisory. Defaults to today.
    - **is_offline**: Indicates if the app is in offline mode. If true, should rely on cached data.
    """

    if is_offline:
        # Placeholder: Logic to fetch cached weather forecast and crop tips
        weather_forecast = "Cached 3-day weather forecast for your area."
        crop_tips = "Offline crop tips for general farming."
        if crop_type:
            crop_tips = f"Offline tips for {crop_type}."
        forecast_data = None
    else:
        # Call Open-Meteo API for real weather forecast
        try:
            url = (
                f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}"
                f"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode"
                f"&timezone=Africa%2FAddis_Ababa"
            )
            resp = requests.get(url, timeout=10)
            resp.raise_for_status()
            data = resp.json()
            # Parse relevant forecast data
            forecast_data = {
                "dates": data.get("daily", {}).get("time", []),
                "temp_max": data.get("daily", {}).get("temperature_2m_max", []),
                "temp_min": data.get("daily", {}).get("temperature_2m_min", []),
                "precipitation": data.get("daily", {}).get("precipitation_sum", []),
                "weathercode": data.get("daily", {}).get("weathercode", [])
            }
            weather_forecast = "3-day forecast from Open-Meteo."
        except Exception as e:
            weather_forecast = f"Could not fetch weather forecast: {e}"
            forecast_data = None
        crop_tips = "Online, tailored crop advice."
        if crop_type:
            crop_tips = f"Detailed online advice for {crop_type} at your location."

    return {
        "location": {"latitude": latitude, "longitude": longitude},
        "crop_type": crop_type,
        "date": request_date,
        "is_offline": is_offline,
        "weather_forecast": weather_forecast,
        "forecast_data": forecast_data,
        "crop_advisory": crop_tips
    }
