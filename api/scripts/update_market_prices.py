import json
import datetime
import requests
import os

# CONFIGURABLE: Replace with your real market price API endpoint if available
API_URL = "https://api.mockmarketprices.com/v1/prices"  # <-- Replace with real endpoint
API_KEY = os.getenv("MARKET_PRICES_API_KEY")  # Optionally use an API key

# Output path for the JSON file
DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "market_prices.json")

# Example: expected response from real API
# [
#   {"region": "Oromia", "crop_type": "maize", "date": "2025-06-10", "price_per_kg": 18.5, "currency": "ETB"},
#   ...
# ]

def fetch_market_prices():
    """Fetch market prices from external API. Replace with actual API logic."""
    headers = {"Authorization": f"Bearer {API_KEY}"} if API_KEY else {}
    try:
        response = requests.get(API_URL, headers=headers, timeout=10)
        response.raise_for_status()
        data = response.json()
        # Optionally transform data to match your schema
        return data
    except Exception as e:
        print(f"Error fetching market prices: {e}")
        return None

def update_market_prices():
    prices = fetch_market_prices()
    if not prices:
        print("No data fetched. Aborting update.")
        return
    # Validate/transform entries if needed
    for entry in prices:
        # Ensure all required fields exist
        for field in ["region", "crop_type", "date", "price_per_kg", "currency"]:
            if field not in entry:
                print(f"Missing field {field} in entry: {entry}")
                return
        # Optionally: validate date format
        try:
            datetime.datetime.strptime(entry["date"], "%Y-%m-%d")
        except Exception as e:
            print(f"Invalid date format in entry: {entry}")
            return
    # Write to JSON file
    with open(DATA_PATH, "w", encoding="utf-8") as f:
        json.dump(prices, f, ensure_ascii=False, indent=2)
    print(f"market_prices.json updated with {len(prices)} entries.")

if __name__ == "__main__":
    update_market_prices()
