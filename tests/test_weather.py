from fastapi.testclient import TestClient
from api.main import app
import types

client = TestClient(app)

# Monkeypatch requests.get used in weather route
import api.routes.weather as weather_route

def _fake_get(url, timeout=10):
    sample = {
        "hourly": {
            "time": ["2025-06-14T00:00", "2025-06-14T01:00"],
            "temperature_2m": [20.5, 20.1],
            "precipitation": [0.0, 0.1],
        }
    }
    return types.SimpleNamespace(json=lambda: sample)

weather_route.requests.get = _fake_get  # type: ignore

def test_weather_endpoint():
    resp = client.get("/api/v1/weather?lat=9.1&lon=40.4")
    assert resp.status_code == 200
    data = resp.json()
    assert data["latitude"] == 9.1
    assert len(data["hours"]) == 2
