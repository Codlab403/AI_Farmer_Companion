import os
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai
from datetime import datetime, timezone

from ..core.supabase_client import get_supabase_client
from ..core.security import get_current_user_id

# Load environment variables and configure the Gemini API
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if not GEMINI_API_KEY:
    raise ValueError("GEMINI_API_KEY is not set in the environment variables.")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')

router = APIRouter(
    prefix="/chat",
    tags=["Chat"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

class UserQuery(BaseModel):
    text_input: str
    language_code: str = 'en'

@router.post("/ask", summary="Process a user's text query")
async def ask_assistant(query: UserQuery, current_user_id: str = Depends(get_current_user_id)):
    try:
        print(f"--- Received query: '{query.text_input}' in {query.language_code} ---")

        # 1. Construct a prompt for the Gemini model
        prompt = (
            f"You are an expert agricultural assistant for Ethiopian farmers. "
            f"Your goal is to provide accurate, helpful, and concise advice. "
            f"Please respond in {query.language_code}, as that is the user's preferred language.\n\n"
            f"User's question: {query.text_input}"
        )

        # 2. Generate the AI response
        print("--- Sending request to Gemini API... ---")
        response = await model.generate_content_async(prompt)
        ai_response_text = response.text
        print(f"--- Received response from Gemini ---")

        # 3. Log the interaction to Supabase
        supabase = get_supabase_client()
        if supabase:
            try:
                # Ensure the user exists in profiles (foreign-key target)
                try:
                    supabase.table('profiles').upsert({'id': current_user_id}).execute()
                except Exception:
                    # Ignore duplicate or other non-fatal issues
                    pass

                # Now insert chat history row
                supabase.table('chat_history').insert({
                    'user_id': current_user_id,
                    'query_text': query.text_input,
                    'response_text': ai_response_text,
                    'language': query.language_code,
                    'timestamp': datetime.now(timezone.utc).isoformat(),
                }).execute()
                print("--- Chat history logged to Supabase ---")
            except Exception as e:
                print(f"--- Supabase logging error: {e} ---") # Non-critical error

        # 4. Return the AI-generated response to the client
        return {"response": ai_response_text}

    except Exception as e:
        print(f"--- CRITICAL ERROR in ask_assistant: {e} ---")
        raise HTTPException(status_code=500, detail="An error occurred while processing your request.")
        print(f"!!! UNHANDLED EXCEPTION in ask_assistant: {type(e).__name__} - {str(e)} !!!")
        import traceback
        traceback.print_exc()
        # Return a 500 error with the exception details
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {type(e).__name__} - {str(e)}"
        )
