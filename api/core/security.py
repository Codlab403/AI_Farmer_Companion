import os
from typing import Optional
import requests # Keep requests import for potential future use or other parts of the app
from datetime import datetime, timedelta

from fastapi import HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

SECRET_KEY = os.getenv("SUPABASE_JWT_SECRET")
SUPABASE_URL = os.getenv("SUPABASE_URL")
# Changed ALGORITHM to HS256 to use the shared secret for verification
ALGORITHM = "HS256"

if not SECRET_KEY:
     # Raise error if SECRET_KEY is not set, as it's required for HS256
    raise EnvironmentError("SUPABASE_JWT_SECRET environment variable not set. Required for HS256 verification.")

# Construct the expected audience and issuer from SUPABASE_URL (still good practice to verify)
if not SUPABASE_URL:
    print("Warning: SUPABASE_URL environment variable not set. Issuer verification will be skipped.")
    EXPECTED_ISSUER = None
else:
    EXPECTED_ISSUER = f"{SUPABASE_URL}/auth/v1"

EXPECTED_AUDIENCE = "authenticated" # Default for Supabase user JWTs

reusable_oauth2 = HTTPBearer(
    scheme_name="Bearer"
)

# Removed JWKS caching and fetching logic as it's not needed for HS256

def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(reusable_oauth2)) -> str:
    """
    Decodes and verifies the JWT token from the Authorization header using HS256 and the shared secret.
    Returns the user ID (sub claim) if the token is valid.
    Raises HTTPException if the token is invalid or missing.
    """
    if credentials is None:
        print("DEBUG - No credentials provided")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated: No credentials provided",
            headers={"WWW-Authenticate": "Bearer"},
        )
    token = credentials.credentials
    print(f"DEBUG - Received JWT token: {token}")

    try:
        # Ensure SECRET_KEY is not None before decoding (should be caught by module-level check, but for Pylance)
        if SECRET_KEY is None:
             print("ERROR - SUPABASE_JWT_SECRET is not set at runtime.")
             raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Server configuration error: JWT secret not set.",
            )

        # Decode and verify the token using the shared secret and HS256
        payload = jwt.decode(
            token,
            SECRET_KEY, # Use the shared secret
            algorithms=[ALGORITHM], # Use HS256
            audience=EXPECTED_AUDIENCE,
            issuer=EXPECTED_ISSUER, # Will be None if SUPABASE_URL is not set
            options={
                "verify_signature": True,
                "verify_aud": True,
                # Only verify issuer if SUPABASE_URL is set
                "verify_iss": EXPECTED_ISSUER is not None,
                "require_exp": True # Ensure token has an expiration time
            }
        )
        print(f"DEBUG - JWT payload: {payload}")

        user_id = payload.get("sub")
        if not user_id:
            print("DEBUG - Token payload missing 'sub' claim")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: Missing user ID (sub claim)",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return user_id

    except JWTError as e:
        print(f"DEBUG - JWT validation failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Could not validate credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        print(f"ERROR - Unexpected error during authentication: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Authentication error: {str(e)}",
        )
