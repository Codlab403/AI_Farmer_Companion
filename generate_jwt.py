import os
from jose import jwt
from datetime import datetime, timedelta, timezone
from dotenv import load_dotenv
from pathlib import Path

if __name__ == "__main__":
    # Load .env file from the project root (where this script is expected to be)
    env_path = Path(__file__).resolve().parent / ".env"
    load_dotenv(dotenv_path=env_path)

    secret_key = os.getenv("SUPABASE_JWT_SECRET")
    supabase_url = os.getenv("SUPABASE_URL")
    algorithm = "HS256" # Matches security.py

    if not secret_key or not supabase_url:
        print("Error: SUPABASE_JWT_SECRET or SUPABASE_URL not found in .env file or environment.")
        exit(1)

    # Claims for the JWT
    # These must align with expectations in api/core/security.py
    payload = {
        "sub": "test-user-from-script",  # User ID
        "aud": "authenticated",          # Expected audience
        "iss": f"{supabase_url}/auth/v1", # Expected issuer
        "exp": datetime.now(timezone.utc) + timedelta(hours=1), # Expiration time (1 hour from now)
        "iat": datetime.now(timezone.utc)  # Issued at time
    }

    try:
        encoded_jwt = jwt.encode(payload, secret_key, algorithm=algorithm)
        print(encoded_jwt)
    except Exception as e:
        print(f"Error encoding JWT: {e}")
        exit(1)
