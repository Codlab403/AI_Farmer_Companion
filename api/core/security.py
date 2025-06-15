import os
from typing import Optional
import requests

from fastapi import HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt

SECRET_KEY = os.getenv("SUPABASE_JWT_SECRET")
SUPABASE_URL = os.getenv("SUPABASE_URL")
ALGORITHM = "RS256"

# Construct the expected audience and issuer from SUPABASE_URL
# Example SUPABASE_URL: https://<project_ref>.supabase.co
# Expected ISSUER: https://<project_ref>.supabase.co/auth/v1
# Expected AUDIENCE for user JWTs is typically 'authenticated'

if not SUPABASE_URL:
    raise EnvironmentError("SUPABASE_URL environment variable not set.")

EXPECTED_ISSUER = f"{SUPABASE_URL}/auth/v1"
EXPECTED_AUDIENCE = "authenticated" # Default for Supabase user JWTs

reusable_oauth2 = HTTPBearer(
    scheme_name="Bearer"
)

from fastapi import Depends

def get_current_user_id(credentials: HTTPAuthorizationCredentials = Depends(reusable_oauth2)) -> str:
    """
    Decodes and verifies the JWT token from the Authorization header.
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
        # Validate token using Supabase JWKS (RS256)
        jwks_url = f"{SUPABASE_URL}/auth/v1/keys"
        print(f"DEBUG - Fetching JWKS from: {jwks_url}")
        jwks = requests.get(jwks_url, timeout=5).json().get("keys", [])
        print(f"DEBUG - JWKS keys count: {len(jwks)}")
        for key in jwks:
            try:
                payload = jwt.decode(
                    token,
                    key,
                    algorithms=["RS256"],
                    options={"verify_aud": False}
                )
                print(f"DEBUG - JWT payload: {payload}")
                user_id = payload.get("sub")
                if user_id:
                    return user_id
            except JWTError as jwt_err:
                print(f"DEBUG - JWTError for key: {jwt_err}")
                continue
        print("DEBUG - No valid key found for token.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials with RS256 keys",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except Exception as e:
        print(f"DEBUG - Exception during JWT validation: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Authentication error: {str(e)}",
        )

