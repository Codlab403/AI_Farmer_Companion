import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables from .env file in the project root
# Adjust the path if your .env file is located elsewhere relative to this script's execution context
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
load_dotenv(os.path.join(project_root, '.env'))

SUPABASE_URL: str = os.environ.get("SUPABASE_URL")
SUPABASE_ANON_KEY: str = os.environ.get("SUPABASE_KEY")  # Public anon key (fallback)
SUPABASE_SERVICE_KEY: str = os.environ.get("SUPABASE_SERVICE_KEY")  # Full-privilege service role key (preferred for server)

# Choose the strongest available key: service > anon
chosen_key = SUPABASE_SERVICE_KEY or SUPABASE_ANON_KEY

if not SUPABASE_URL or not chosen_key:
    print("Warning: SUPABASE_URL or Supabase key env vars not fully set (SUPABASE_SERVICE_KEY / SUPABASE_KEY).")
    print(f"Attempted to load .env from: {os.path.join(project_root, '.env')}")
    supabase: Client = None
else:
    try:
        supabase: Client = create_client(SUPABASE_URL, chosen_key)
        key_type = "service" if SUPABASE_SERVICE_KEY else "anon"
        print(f"Supabase client initialized with {key_type} key for URL: {SUPABASE_URL[:20]}...")
    except Exception as e:
        print(f"Error initializing Supabase client: {e}")
        supabase: Client = None

def get_supabase_client() -> Client:
    """Returns the initialized Supabase client."""
    if supabase is None:
        # This could happen if env vars were missing or initialization failed.
        # Depending on strictness, you might re-attempt initialization or raise an error.
        print("Error: Supabase client is not initialized. Check environment variables and logs.")
        # raise Exception("Supabase client not initialized.") # Uncomment to make it strict
    return supabase
