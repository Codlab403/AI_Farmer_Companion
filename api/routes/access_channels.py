from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict

from fastapi import Depends
from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/access-channels",
    tags=["Access Channels (USSD & IVR)"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

# --- USSD Models and Endpoint ---
class UssdRequest(BaseModel):
    session_id: str
    phone_number: str
    user_input: Optional[str] = None # What the user dialed, e.g., '1', '2*3', or initial empty string
    # Additional fields like service_code might be sent by the USSD gateway
    service_code: Optional[str] = None 

class UssdResponse(BaseModel):
    session_id: str
    message: str # The text to display to the user
    # The USSD gateway usually determines if the session continues or ends based on the message prefix/content
    # e.g., "CON Welcome to Farmer's Companion..." vs "END Thank you..."
    # We'll just return the message, and the gateway handles session control.

# Simulate simple session state using session_id to store the language (in real USSD, use a session store)

LANGUAGES = {"1": "en", "2": "am"}
MENU_TEXT = {
    "en": {
        "welcome": "CON Welcome to Farmer's Companion! Please select your language:\n1. English\n2. አማርኛ (Amharic)",
        "main": "CON Main Menu:\n1. Crop Info\n2. Pest Help\n3. Market Prices",
        "crop": "CON Crop Info selected. Enter your region:",
        "pest": "CON Pest Help selected. Describe the issue or send photo later:",
        "price": "CON Market Prices selected. Enter crop name:",
        "invalid": "CON Invalid input. Please try again.",
        "thank_you": "END Thank you for using Farmer's Companion!"
    },
    "am": {
        "welcome": "CON እንኳን ደህና መጡ ወደ ገበሬ ባልደረባ! ቋንቋ ይምረጡ:\n1. English\n2. አማርኛ",
        "main": "CON ዋና ምናሌ:\n1. የእርሻ መረጃ\n2. የተባባሪ መረጃ\n3. የገበያ ዋጋ",
        "crop": "CON የእርሻ መረጃ ተመርጧል። ክልልዎን ያስገቡ:",
        "pest": "CON የተባባሪ መረጃ ተመርጧል። ችግሩን ይግለጹ ወይም ፎቶ ይላኩ:",
        "price": "CON የገበያ ዋጋ ተመርጧል። የእርሻ ስም ያስገቡ:",
        "invalid": "CON የተሳሳተ ግብዓት። እባክዎ ደግመው ይሞክሩ።",
        "thank_you": "END አመሰግናለሁ ወደ ገበሬ ባልደረባ ስለ መጡ!"
    }
}

# Simulate session storage (in-memory, for demonstration only)
session_language = {}
session_state = {}

@router.post("/ussd", response_model=UssdResponse, summary="Handle USSD interaction")
async def handle_ussd_request(request: UssdRequest):
    sid = request.session_id
    user_input = (request.user_input or "").strip()
    lang = session_language.get(sid)
    state = session_state.get(sid, {"step": "lang"})

    # Step 1: Language selection
    if not lang:
        if user_input in LANGUAGES:
            lang = LANGUAGES[user_input]
            session_language[sid] = lang
            state = {"step": "main"}
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])
        else:
            return UssdResponse(session_id=sid, message=MENU_TEXT["en"]["welcome"])

    # Step 2: Main menu
    if state["step"] == "main":
        if user_input == "1":
            state["step"] = "crop_region"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_region"])
        elif user_input == "2":
            state["step"] = "pest_crop"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_crop"])
        elif user_input == "3":
            state["step"] = "price_crop"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["price_crop"])
        elif user_input == "0":
            session_language.pop(sid, None)
            session_state.pop(sid, None)
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["thank_you"])
        else:
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["invalid"])

    # Step 3: Crop Info flow
    if state["step"] == "crop_region":
        if user_input == "0":
            state["step"] = "main"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])
        state["region"] = user_input
        state["step"] = "crop_type"
        session_state[sid] = state
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_type"] + "\n0. Back")
    if state["step"] == "crop_type":
        if user_input == "0":
            state["step"] = "crop_region"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_region"] + "\n0. Back")
        region = state.get("region", "-")
        crop = user_input
        session_language.pop(sid, None)
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_result"].format(crop=crop, region=region))

    # Step 4: Pest Help flow
    if state["step"] == "pest_crop":
        if user_input == "0":
            state["step"] = "main"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])
        state["crop"] = user_input
        state["step"] = "pest_desc"
        session_state[sid] = state
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_desc"] + "\n0. Back")
    if state["step"] == "pest_desc":
        if user_input == "0":
            state["step"] = "pest_crop"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_crop"] + "\n0. Back")
        crop = state.get("crop", "-")
        session_language.pop(sid, None)
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_result"].format(crop=crop))

    # Step 5: Market Prices flow
    if state["step"] == "price_crop":
        if user_input == "0":
            state["step"] = "main"
            session_state[sid] = state
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])
        state["crop"] = user_input
        # Optionally ask for region here, for now just use crop
        # Load market prices from JSON
        import os, json
        data_path = os.path.join(os.path.dirname(__file__), "..", "data", "market_prices.json")
        with open(data_path, "r", encoding="utf-8") as f:
            all_prices = json.load(f)
        crop = user_input.strip().lower()
        # Find the latest price for the crop (optionally filter by region if you want)
        filtered = [p for p in all_prices if p["crop_type"].lower() == crop]
        if filtered:
            # Get the latest by date
            latest = sorted(filtered, key=lambda x: x["date"], reverse=True)[0]
            price_str = f"{latest['region']}: {latest['price_per_kg']} {latest['currency']} ({latest['date']})"
        else:
            price_str = "Not found"
        session_language.pop(sid, None)
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=f"END {crop.title()} price: {price_str}")

    # Fallback
    return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["invalid"])

@router.post("/ussd", response_model=UssdResponse, summary="Handle USSD interaction")
async def handle_ussd_request(request: UssdRequest):
    """
    Processes a USSD request from a mobile user with language selection (English/Amharic).
    """
    sid = request.session_id
    user_input = (request.user_input or "").strip()
    lang = session_language.get(sid)

    # Step 1: Language selection
    if not lang:
        if user_input in LANGUAGES:
            lang = LANGUAGES[user_input]
            session_language[sid] = lang
            response_message = MENU_TEXT[lang]["main"]
        else:
            response_message = MENU_TEXT["en"]["welcome"]
            return UssdResponse(session_id=sid, message=response_message)
    else:
        # Step 2: Main menu and submenus
        if user_input == "1":
            response_message = MENU_TEXT[lang]["crop"]
        elif user_input == "2":
            response_message = MENU_TEXT[lang]["pest"]
        elif user_input == "3":
            response_message = MENU_TEXT[lang]["price"]
        elif user_input == "0":
            response_message = MENU_TEXT[lang]["thank_you"]
        else:
            response_message = MENU_TEXT[lang]["invalid"]
    return UssdResponse(session_id=sid, message=response_message)

# --- IVR (Voice) Models and Endpoint ---
class IvrEventRequest(BaseModel):
    call_id: str
    phone_number: str
    event_type: str # e.g., 'new_call', 'dtmf_input', 'speech_transcribed', 'hangup'
    dtmf_input: Optional[str] = None
    speech_to_text_result: Optional[str] = None
    language_preference: Optional[str] = 'am' # Default to Amharic

class IvrActionResponse(BaseModel):
    call_id: str
    actions: list # List of actions, e.g., play audio, get input, transfer, hangup
    # Example action: {"action": "play_audio", "url": "http://example.com/audio/welcome_am.mp3"}
    # Example action: {"action": "get_speech_input", "prompt_url": ".../ask_question.mp3", "language": "am"}

@router.post("/ivr", response_model=IvrActionResponse, summary="Handle IVR (voice call) interaction")
async def handle_ivr_event(request: IvrEventRequest):
    """
    Processes an event from an IVR system (e.g., a new call, DTMF input, transcribed speech).

    - **call_id**: Unique ID for the voice call.
    - **phone_number**: The caller's phone number.
    - **event_type**: Type of IVR event.
    - **dtmf_input**: DTMF digits entered by the user.
    - **speech_to_text_result**: Transcribed text from user's speech.
    - **language_preference**: User's preferred language.
    """
    actions = []

    if request.event_type == 'new_call':
        actions.append({
            "action": "play_audio", 
            "audio_config": {"text": f"Welcome to the AI Farmer's Companion in {request.language_preference}. Press 1 for Crop Info, 2 for Pest Help.", "language": request.language_preference}
        })
        actions.append({"action": "get_input", "input_type": "dtmf_or_speech", "max_digits": 1, "timeout_ms": 5000})
    elif request.event_type == 'dtmf_input':
        if request.dtmf_input == '1':
            actions.append({"action": "play_audio", "audio_config": {"text": "Crop information selected.", "language": request.language_preference}})
            # Further actions for crop info...
        else:
            actions.append({"action": "play_audio", "audio_config": {"text": "Invalid input.", "language": request.language_preference}})
        actions.append({"action": "hangup"})
    elif request.event_type == 'speech_transcribed':
        # Process speech_to_text_result with Gemini or local model
        actions.append({"action": "play_audio", "audio_config": {"text": f"You said: {request.speech_to_text_result}. Processing...", "language": request.language_preference}})
        actions.append({"action": "hangup"})
    else:
        actions.append({"action": "hangup"})

    return IvrActionResponse(call_id=request.call_id, actions=actions)
