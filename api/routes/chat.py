import os
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from dotenv import load_dotenv
import google.generativeai as genai
from datetime import datetime, timezone

from ..core.supabase_client import get_supabase_client
from ..core.security import get_current_user_id
from ..core.faq_utils import search_faqs # Import the FAQ search utility

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

        supabase = get_supabase_client()
        if not supabase:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Supabase client not initialized.")

        # Ensure the user exists in profiles (foreign-key target)
        try:
            supabase.table('profiles').upsert({'id': current_user_id}).execute()
        except Exception as e:
            print(f"WARNING - Failed to upsert user profile: {e}")
            # This is non-critical, so we'll log and continue.

        # 1. Fetch recent chat history for conversational memory
        chat_history_str = ""
        try:
            # Fetch last 5 messages (adjust as needed for context window limits)
            response = supabase.table('chat_history').select('query_text, response_text') \
                .eq('user_id', current_user_id) \
                .order('timestamp', ascending=False) \
                .limit(5).execute()
            
            history = response.data
            if history:
                # Reverse to get chronological order for prompt
                history.reverse() 
                chat_history_str = "\n\n--- Conversation History ---\n"
                for entry in history:
                    chat_history_str += f"User: {entry['query_text']}\n"
                    chat_history_str += f"Assistant: {entry['response_text']}\n"
                chat_history_str += "--------------------------\n\n"
                print("--- Fetched chat history ---")
            else:
                print("--- No chat history found ---")
        except Exception as e:
            print(f"--- Supabase chat history fetch error: {e} ---")
            chat_history_str = "\n\n(Could not retrieve conversation history due to an error.)\n\n" # Indicate error to AI

        # 2. Implement RAG (Retrieval Augmented Generation) for FAQs
        faq_context = ""
        try:
            relevant_faqs = search_faqs(query.text_input, top_n=2) # Get top 2 relevant FAQs
            if relevant_faqs:
                faq_context = "\n\n--- Relevant FAQs ---\n"
                for i, faq in enumerate(relevant_faqs):
                    faq_context += f"Q{i+1}: {faq['question']}\n"
                    faq_context += f"A{i+1}: {faq['answer']}\n"
                faq_context += "---------------------\n\n"
                print("--- Fetched relevant FAQs ---")
            else:
                print("--- No relevant FAQs found ---")
        except Exception as e:
            print(f"--- FAQ search error: {e} ---")
            faq_context = "\n\n(Could not retrieve FAQ context due to an error.)\n\n" # Indicate error to AI

        # 3. Fetch farm profile data for personalization
        farm_profile_context = ""
        try:
            response = supabase.table('farm_profiles').select('*').eq('user_id', current_user_id).single().execute()
            profile_data = response.data
            if profile_data:
                farm_profile_context = "\n\n--- Farm Profile ---\n"
                farm_profile_context += f"Region: {profile_data.get('region', 'N/A')}\n"
                farm_profile_context += f"Crop Focus: {profile_data.get('crop_focus', 'N/A')}\n"
                farm_profile_context += f"Land Size: {profile_data.get('land_size', 'N/A')}\n"
                farm_profile_context += "--------------------\n\n"
                print("--- Fetched farm profile ---")
            else:
                print("--- No farm profile found ---")
        except Exception as e:
            print(f"--- Farm profile fetch error: {e} ---")
            farm_profile_context = "\n\n(Could not retrieve farm profile due to an error.)\n\n" # Indicate error to AI


        # 4. Construct a prompt for the Gemini model
        prompt = (
            f"You are an expert agricultural assistant for Ethiopian farmers. "
            f"Your goal is to provide accurate, helpful, and concise advice. "
            f"Please respond in {query.language_code}, as that is the user's preferred language.\n\n"
            f"{chat_history_str}" # Include conversation history
            f"{faq_context}"     # Include FAQ context
            f"{farm_profile_context}" # Include farm profile context
            f"User's current question: {query.text_input}"
        )

        # 4. Generate the AI response
        print("--- Sending request to Gemini API... ---")
        response = await model.generate_content_async(prompt)
        ai_response_text = response.text
        print(f"--- Received response from Gemini ---")

        # 5. Log the interaction to Supabase
        try:
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

        # 6. Return the AI-generated response to the client
        return {"response": ai_response_text}

    except Exception as e:
        print(f"--- CRITICAL ERROR in ask_assistant: {e} ---")
        # Return a 500 error with the exception details (refined error handling)
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {type(e).__name__} - {str(e)}"
        )

class Feedback(BaseModel):
    message_id: str
    feedback_type: str # e.g., 'like', 'dislike'

@router.post("/feedback", summary="Submit feedback for an AI chat message")
async def submit_feedback(
    feedback: Feedback,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    Receives user feedback (like/dislike) for a specific AI chat message and saves it.
    """
    supabase = get_supabase_client()
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase client not initialized.")

    try:
        # Implement logic to save feedback in Supabase
        # Assuming a 'feedback' table exists with columns: user_id, message_id, feedback_type, timestamp
        data_to_save = {
            'user_id': current_user_id,
            'message_id': feedback.message_id,
            'feedback_type': feedback.feedback_type,
            'timestamp': datetime.now(timezone.utc).isoformat(),
        }
        # Insert the feedback data into the 'feedback' table
        response = supabase.table('feedback').insert(data_to_save).execute()
        print(f"DEBUG - Supabase feedback insert response: {response.data}")

        # Return a success message
        return {"message": "Feedback saved successfully!"}

    except Exception as e:
        print(f"ERROR - Failed to save feedback: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred while saving feedback: {str(e)}")
