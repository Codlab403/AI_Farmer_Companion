from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, Dict

from fastapi import Depends
from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/access-channels",
    tags=["Access Channels (USSD & IVR)"],
    # USSD and IVR typically do not use JWT authentication in the same way as web/mobile.
    # Authentication/identification is usually handled via gateway-provided info (e.g., phone number).
    # Removing JWT dependency for these endpoints.
    # dependencies=[Depends(get_current_user_id)],
    # responses={401: {"description": "Unauthorized"}} # 401 is less likely without JWT dependency
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
        "main": "CON Main Menu:\n1. Crop Info\n2. Pest Help\n3. Market Prices\n0. Exit",
        "crop_info_prompt": "CON Crop Info selected. Enter your region:\n0. Back",
        "crop_type_prompt": "CON Enter crop type (e.g., maize, teff):\n0. Back",
        "crop_result": "END Crop: {crop}, Region: {region} - Advisory: Use disease-resistant seeds.", # Placeholder
        "pest_help_prompt": "CON Pest Help selected. Describe the issue or send photo later:\n0. Back",
        "pest_result": "END Pest for {crop}: Monitor for symptoms. Consult local extension for specific treatment.", # Placeholder
        "market_prices_prompt": "CON Market Prices selected. Enter crop name:\n0. Back",
        "invalid_input": "CON Invalid input. Please try again.",
        "thank_you": "END Thank you for using Farmer's Companion!"
    },
    "am": {
        "welcome": "CON እንኳን ደህና መጡ ወደ ገበሬ ባልደረባ! ቋንቋ ይምረጡ:\n1. English\n2. አማርኛ",
        "main": "CON ዋና ምናሌ:\n1. የእርሻ መረጃ\n2. የተባባሪ መረጃ\n3. የገበያ ዋጋ\n0. ውጣ",
        "crop_info_prompt": "CON የእርሻ መረጃ ተመርጧል። ክልልዎን ያስገቡ:\n0. ተመለስ",
        "crop_type_prompt": "CON የእርሻ አይነት ያስገቡ (ለምሳሌ: በቆሎ, ጤፍ):\n0. ተመለስ",
        "crop_result": "END ሰብል: {crop}, ክልል: {region} - ምክር: በሽታን የሚቋቋሙ ዘሮችን ይጠቀሙ።", # Placeholder
        "pest_help_prompt": "CON የተባባሪ መረጃ ተመርጧል። ችግሩን ይግለጹ ወይም ፎቶ ይላኩ:\n0. ተመለስ",
        "pest_result": "END ለ{crop} ተባይ: ምልክቶችን ይከታተሉ። ለተለየ ህክምና የአካባቢውን ባለሙያ ያማክሩ።", # Placeholder
        "market_prices_prompt": "CON የገበያ ዋጋ ተመርጧል። የእርሻ ስም ያስገቡ:\n0. ተመለስ",
        "invalid_input": "CON የተሳሳተ ግብዓት። እባክዎ ደግመው ይሞክሩ።",
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
    state = session_state.get(sid, {"step": "lang_selection"}) # Initial state

    # Handle language selection
    if state["step"] == "lang_selection":
        if user_input in LANGUAGES:
            lang = LANGUAGES[user_input]
            session_language[sid] = lang
            session_state[sid] = {"step": "main_menu"}
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])
        else:
            # Default to English if no valid language selected yet
            return UssdResponse(session_id=sid, message=MENU_TEXT["en"]["welcome"])

    # Ensure language is set for subsequent steps
    if not lang:
        # This should ideally not happen if lang_selection is handled first
        return UssdResponse(session_id=sid, message=MENU_TEXT["en"]["welcome"])

    # Handle main menu and sub-flows
    if user_input == "0": # Universal back/exit
        if state["step"] == "main_menu":
            session_language.pop(sid, None)
            session_state.pop(sid, None)
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["thank_you"])
        else:
            session_state[sid] = {"step": "main_menu"}
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["main"])

    if state["step"] == "main_menu":
        if user_input == "1": # Crop Info
            session_state[sid] = {"step": "crop_info_region_input"}
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_info_prompt"])
        elif user_input == "2": # Pest Help
            session_state[sid] = {"step": "pest_help_crop_input"}
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_help_prompt"])
        elif user_input == "3": # Market Prices
            session_state[sid] = {"step": "market_prices_crop_input"}
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["market_prices_prompt"])
        else:
            return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["invalid_input"])

    elif state["step"] == "crop_info_region_input":
        state["region"] = user_input
        state["step"] = "crop_info_type_input"
        session_state[sid] = state
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["crop_type_prompt"])
    elif state["step"] == "crop_info_type_input":
        region = state.get("region", "Unknown")
        crop = user_input
        # In a real app, call backend API for crop info
        response_message = MENU_TEXT[lang]["crop_result"].format(crop=crop, region=region)
        session_language.pop(sid, None) # End session after result
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=response_message)

    elif state["step"] == "pest_help_crop_input":
        state["crop"] = user_input
        state["step"] = "pest_help_desc_input"
        session_state[sid] = state
        return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["pest_help_prompt"]) # Re-using prompt
    elif state["step"] == "pest_help_desc_input":
        crop = state.get("crop", "Unknown")
        # In a real app, call backend API for pest diagnosis
        response_message = MENU_TEXT[lang]["pest_result"].format(crop=crop)
        session_language.pop(sid, None) # End session after result
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=response_message)

    elif state["step"] == "market_prices_crop_input":
        crop = user_input.strip().lower()
        # Load market prices from JSON (direct read for simplicity, could use shared cache)
        import os, json
        data_path = os.path.join(os.path.dirname(__file__), "..", "data", "market_prices.json")
        try:
            with open(data_path, "r", encoding="utf-8") as f:
                all_prices = json.load(f)
            filtered = [p for p in all_prices if p.get("crop_type", "").lower() == crop]
            if filtered:
                latest = sorted(filtered, key=lambda x: x.get("date", "0000-00-00"), reverse=True)[0]
                price_str = f"{latest.get('region', 'N/A')}: {latest.get('price_per_kg', 0.0)} {latest.get('currency', 'ETB')} ({latest.get('date', 'N/A')})"
            else:
                price_str = "Not found"
            response_message = f"END {crop.title()} price: {price_str}"
        except Exception as e:
            print(f"ERROR - Failed to fetch market price for USSD: {e}")
            response_message = MENU_TEXT[lang]["invalid_input"] # Or a more specific error message
        
        session_language.pop(sid, None)
        session_state.pop(sid, None)
        return UssdResponse(session_id=sid, message=response_message)

    # Fallback for unhandled states
    return UssdResponse(session_id=sid, message=MENU_TEXT[lang]["invalid_input"])


# --- IVR (Voice) Models and Endpoint ---
class IvrEventRequest(BaseModel):
    call_id: str
    phone_number: str
    event_type: str # e.g., 'new_call', 'dtmf_input', 'speech_transcribed'
    dtmf_input: Optional[str] = None # DTMF digits entered by the user
    speech_to_text_result: Optional[str] = None # Transcribed text from user's speech
    language_preference: Optional[str] = None # User's preferred language (e.g., 'en', 'am')

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
    lang = request.language_preference or "en" # Default to English

    if request.event_type == 'new_call':
        actions.append({
            "action": "play_audio", 
            "audio_config": {"text": f"Welcome to the AI Farmer's Companion. Please select your language. Press 1 for English, 2 for Amharic.", "language": "en"}
        })
        actions.append({"action": "get_input", "input_type": "dtmf", "max_digits": 1, "timeout_ms": 5000})
    elif request.event_type == 'dtmf_input':
        if request.dtmf_input == '1':
            actions.append({"action": "play_audio", "audio_config": {"text": "You have selected English. Press 1 for Crop Info, 2 for Pest Help, 3 for Market Prices.", "language": "en"}})
            actions.append({"action": "get_input", "input_type": "dtmf", "max_digits": 1, "timeout_ms": 5000})
        elif request.dtmf_input == '2':
            actions.append({"action": "play_audio", "audio_config": {"text": "አማርኛ መርጠዋል። ለሰብል መረጃ 1 ይጫኑ፣ ለተባይ መረጃ 2 ይጫኑ፣ ለገበያ ዋጋ 3 ይጫኑ።", "language": "am"}})
            actions.append({"action": "get_input", "input_type": "dtmf", "max_digits": 1, "timeout_ms": 5000})
        else:
            actions.append({"action": "play_audio", "audio_config": {"text": "Invalid input. Please try again.", "language": lang}})
            actions.append({"action": "hangup"}) # Or loop back to main menu
    elif request.event_type == 'speech_transcribed':
        # Process speech_to_text_result with Gemini or local model
        # For simplicity, just echo back and hangup
        actions.append({"action": "play_audio", "audio_config": {"text": f"You said: {request.speech_to_text_result}. Processing your request.", "language": lang}})
        actions.append({"action": "hangup"})
    else:
        actions.append({"action": "hangup"})

    return IvrActionResponse(call_id=request.call_id, actions=actions)
