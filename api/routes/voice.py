import os
import tempfile
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from typing import Optional
from google.cloud import speech_v1p1beta1 as speech # Use the beta client for more features if needed

from ..core.security import get_current_user_id

router = APIRouter(
    prefix="/voice",
    tags=["Voice"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

@router.post("/transcribe", summary="Receive audio and transcribe using Google Cloud Speech-to-Text")
async def transcribe_audio(
    audio_file: UploadFile = File(..., description="Audio file to transcribe"),
    current_user_id: str = Depends(get_current_user_id)
):
    """
    Receives an audio file, transcribes it using Google Cloud Speech-to-Text, and returns the text.
    """
    print(f"DEBUG - Received audio file '{audio_file.filename}' for transcription from user {current_user_id}")

    # Ensure GOOGLE_APPLICATION_CREDENTIALS is set
    if not os.getenv("GOOGLE_APPLICATION_CREDENTIALS"):
        print("ERROR - GOOGLE_APPLICATION_CREDENTIALS environment variable not set.")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Server configuration error: Google Cloud credentials not set."
        )

    try:
        # Create a SpeechClient
        client = speech.SpeechClient()

        # Save the uploaded audio file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=".m4a") as temp_audio_file:
            content = await audio_file.read()
            temp_audio_file.write(content)
            temp_audio_path = temp_audio_file.name
        print(f"DEBUG - Audio file saved temporarily to: {temp_audio_path}")

        # Read the audio file for transcription
        with open(temp_audio_path, "rb") as audio_file_content:
            audio = speech.RecognitionAudio(content=audio_file_content.read())

        # Configure the recognition request
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.AUDIO_FILE_FORMAT_UNSPECIFIED, # Auto-detect encoding
            sample_rate_hertz=44100, # Common sample rate for m4a (AAC)
            language_code="en-US", # Default language, consider making this dynamic
            enable_automatic_punctuation=True,
        )

        # Perform the transcription
        print("DEBUG - Sending audio to Google Cloud Speech-to-Text...")
        response = client.recognize(config=config, audio=audio)
        print("DEBUG - Received response from Google Cloud Speech-to-Text.")

        transcribed_text = ""
        for result in response.results:
            transcribed_text += result.alternatives[0].transcript + " "
        transcribed_text = transcribed_text.strip()

        if not transcribed_text:
            transcribed_text = "No speech detected or transcription failed."

        print(f"DEBUG - Transcribed text: '{transcribed_text}'")

        # Clean up the temporary audio file
        os.unlink(temp_audio_path)
        print(f"DEBUG - Temporary audio file deleted: {temp_audio_path}")

        # Return the transcribed text
        return {"transcribed_text": transcribed_text}

    except Exception as e:
        print(f"ERROR - Failed to transcribe audio: {e}")
        # Clean up temp file if it exists and an error occurred
        if 'temp_audio_path' in locals() and os.path.exists(temp_audio_path):
            os.unlink(temp_audio_path)
            print(f"DEBUG - Temporary audio file deleted after error: {temp_audio_path}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"An error occurred during transcription: {str(e)}")
