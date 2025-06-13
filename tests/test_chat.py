from fastapi.testclient import TestClient
import types
import asyncio

from api.main import app
from api.core import security
from api.routes import chat as chat_route

# Override auth dependency to bypass JWT validation in unit tests

def _override_get_current_user_id():
    return "test-user-id"

app.dependency_overrides[security.get_current_user_id] = _override_get_current_user_id

# Patch Gemini generate_content_async to avoid external API call
async def _fake_generate_content(prompt):
    fake_resp = types.SimpleNamespace(text="pong")
    return fake_resp

chat_route.model.generate_content_async = _fake_generate_content

client = TestClient(app)


def test_chat_ask():
    payload = {"text_input": "ping", "language_code": "en"}
    response = client.post("/api/v1/chat/ask", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["response"] == "pong"
