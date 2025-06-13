from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import Optional, List
from datetime import date

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

    import json
    import os
    from datetime import datetime

    # Load prices from JSON file
    data_path = os.path.join(os.path.dirname(__file__), "..", "data", "market_prices.json")
    with open(data_path, "r", encoding="utf-8") as f:
        all_prices = json.load(f)

    # Filter by region, crop_type, and date
    filtered = [
        p for p in all_prices
        if p["region"].lower() == region.lower()
        and (not crop_type or p["crop_type"].lower() == crop_type.lower())
        and p["date"] == str(price_date)
    ]

    prices = [
        PriceData(
            crop=p["crop_type"],
            price=p["price_per_kg"],
            unit="per kg",
            source="Sample JSON",
            last_updated=datetime.strptime(p["date"], "%Y-%m-%d").date()
        )
        for p in filtered
    ]

    advice_message = "Prices are stable. Consider market demand before selling."
    offline_data_used = True

    if is_offline:
        # Placeholder: Logic to fetch cached market prices for the region
        # This might be a daily sync from a central DB
        advice_message = "Displaying cached prices. Sync when online for latest data."
        return MarketPriceResponse(
            region=region,
            date=price_date,
            prices=prices,
            advice=advice_message,
            offline_data_used=offline_data_used
        )
    else:
        # Placeholder: Logic to fetch live market prices
        # - Connect to ECX data feed
        # - Aggregate data from cooperative reporting systems
        # - Perform trend analysis
        return MarketPriceResponse(
            region=region,
            date=price_date,
            prices=sample_prices, # Use live fetched sample
            advice=advice_message,
            offline_data_used=False
        )
