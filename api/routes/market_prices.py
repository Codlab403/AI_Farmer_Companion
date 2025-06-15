from fastapi import APIRouter, Query, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from datetime import date, datetime
import json
import os

from fastapi import Depends
from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/market-prices",
    tags=["Market Prices"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

class MarketPriceRequest(BaseModel):
    region: str
    crop_type: Optional[str] = None
    price_date: date = date.today()
    is_offline: bool = False

class PriceData(BaseModel):
    crop: str
    price: float
    unit: str # e.g., 'per kg', 'per quintal'
    source: str # e.g., 'ECX', 'Cooperative XYZ'
    last_updated: date

class MarketPriceResponse(BaseModel):
    region: str
    date: date
    prices: List[PriceData]
    advice: Optional[str] = None # e.g., 'Hold' or 'Sell'
    offline_data_used: bool = False

# Cache market prices data
_market_prices_cache = None

def load_market_prices_data():
    """Loads market prices data from the JSON file."""
    global _market_prices_cache
    data_path = os.path.join(os.path.dirname(__file__), "..", "data", "market_prices.json")
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            _market_prices_cache = json.load(f)
        print("DEBUG - Market prices data loaded and cached.")
    except FileNotFoundError:
        print(f"ERROR - Market prices data file not found at {data_path}")
        _market_prices_cache = [] # Initialize as empty list on error
    except json.JSONDecodeError:
        print(f"ERROR - Error decoding market prices data from {data_path}")
        _market_prices_cache = [] # Initialize as empty list on error
    except Exception as e:
        print(f"ERROR - An unexpected error occurred loading market prices: {e}")
        _market_prices_cache = [] # Initialize as empty list on error

# Load data when the module is imported
load_market_prices_data()

# You might want to add a mechanism to periodically refresh the cache in a real application

@router.get("/", response_model=MarketPriceResponse, summary="Get market prices for crops")
async def get_market_prices(
    region: str = Query(..., description="The region for which to fetch market prices."),
    crop_type: Optional[str] = Query(None, description="Optional: Specific crop to filter prices for."),
    price_date: date = Query(date.today(), description="Date for which prices are requested (YYYY-MM-DD)."),
    is_offline: bool = Query(False, description="Indicates if the request is made in offline mode.")
):
    """
    Provides market price information for various crops in a given region.

    - **region**: The agricultural region (e.g., 'Amhara', 'Oromia').
    - **crop_type**: Optional. Filter by a specific crop (e.g., 'coffee', 'sesame').
    - **price_date**: The date for which the price information is sought. Defaults to today.
    - **is_offline**: Indicates if the app is in offline mode. If true, should rely on cached data.
    """

    # Use the cached data
    all_prices = _market_prices_cache

    if not all_prices:
         raise HTTPException(status_code=500, detail="Market prices data not available.")

    # Filter by region, crop_type, and date
    filtered = [
        p for p in all_prices
        if p.get("region", "").lower() == region.lower()
        and (not crop_type or p.get("crop_type", "").lower() == crop_type.lower())
        and p.get("date") == str(price_date)
    ]

    prices = []
    for p in filtered:
        try:
            prices.append(
                PriceData(
                    crop=p.get("crop_type", "Unknown"),
                    price=float(p.get("price_per_kg", 0.0)),
                    unit=p.get("currency", "ETB") + "/kg", # Assuming currency is unit for simplicity
                    source=p.get("source", "Sample JSON"),
                    last_updated=datetime.strptime(p.get("date", str(date.today())), "%Y-%m-%d").date()
                )
            )
        except (ValueError, TypeError) as e:
            print(f"WARNING - Could not parse market price data: {p} - {e}")
            continue # Skip this entry if parsing fails


    advice_message = "Prices are stable. Consider market demand before selling."

    if is_offline:
        advice_message = "Displaying cached prices. Sync when online for latest data."
        return MarketPriceResponse(
            region=region,
            date=price_date,
            prices=prices,
            advice=advice_message,
            offline_data_used=True
        )
    else:
        # When online, attempt to fetch live data (currently uses cached JSON data as placeholder)
        # Placeholder: Logic to fetch live market prices
        advice_message = "Displaying available prices."
        return MarketPriceResponse(
            region=region,
            date=price_date,
            prices=prices,
            advice=advice_message,
            offline_data_used=False
        )
