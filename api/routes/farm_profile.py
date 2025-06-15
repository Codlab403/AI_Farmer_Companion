from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional

from ..core.security import get_current_user_id
from ..core.supabase_client import get_supabase_client

router = APIRouter(
    prefix="/farm-profile",
    tags=["Farm Profile"],
    dependencies=[Depends(get_current_user_id)],
    responses={401: {"description": "Unauthorized"}}
)

class FarmProfile(BaseModel):
    region: str
    crop_focus: Optional[str] = None
    land_size: Optional[float] = None # in hectares or other unit

@router.post("/", summary="Create or update farm profile for the current user")
async def create_or_update_farm_profile(
    profile: FarmProfile,
    current_user_id: str = Depends(get_current_user_id)
):
    """
    Receives farm profile data and saves it to the database for the authenticated user.
    """
    supabase = get_supabase_client()
    if not supabase:
        raise HTTPException(status_code=500, detail="Supabase client not initialized.")

    try:
        # Data to save or update in the 'farm_profiles' table
        data_to_save = {
            'user_id': current_user_id,
            'region': profile.region,
            'crop_focus': profile.crop_focus,
            'land_size': profile.land_size,
        }
        
        # Use upsert to insert a new record or update an existing one based on 'user_id'
        response = supabase.table('farm_profiles').upsert(data_to_save, on_conflict='user_id').execute()
        
        print(f"DEBUG - Supabase upsert response for farm profile: {response.data}")

        # Return a success message
        return {"message": "Farm profile saved successfully!", "data": response.data}

    except Exception as e:
        print(f"ERROR - Failed to save farm profile: {e}")
        raise HTTPException(status_code=500, detail=f"An error occurred while saving the farm profile: {str(e)}")
