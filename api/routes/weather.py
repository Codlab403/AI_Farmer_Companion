"""Weather routes using Open-Meteo public API (no key needed).
For production you can swap to Tomorrow.io and load an API key from env vars.
"""
from fastapi import APIRouter, HTTPException, Query
import requests

router = APIRouter()

DEFAULT_LAT = 9.145  # Ethiopia approx centre
DEFAULT_LON = 40.48967

@router.get("/weather", summary="24-hour weather forecast")
async def get_weather(
    lat: float = Query(DEFAULT_LAT, description="Latitude"),
    lon: float = Query(DEFAULT_LON, description="Longitude"),
):
    """Return simplified 24-hour hourly forecast for temperature and precipitation.

    Uses free Open-Meteo endpoint (no API key). In production this can be swapped for
    Tomorrow.io by changing the base URL and adding your token.
    """
    url = (
        "https://api.open-meteo.com/v1/forecast"
        f"?latitude={lat}&longitude={lon}&hourly=temperature_2m,precipitation"
        "&timezone=Africa%2FAddis_Ababa&forecast_days=1"
    )
    try:
        resp = requests.get(url, timeout=10)
        data = resp.json()
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather service error: {exc}")

    if "hourly" not in data:
        raise HTTPException(status_code=502, detail="Invalid weather response")

    # Build concise result
    result = {
        "latitude": lat,
        "longitude": lon,
        "hours": [
            {
                "time": t,
                "temperature_c": temp,
                "precip_mm": prec,
            }
            for t, temp, prec in zip(
                data["hourly"]["time"],
                data["hourly"]["temperature_2m"],
                data["hourly"]["precipitation"],
            )
        ]
    }
    return result
