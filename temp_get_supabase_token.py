import os
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Get Supabase credentials from environment variables
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_KEY") # This is the anon key

# --- IMPORTANT: Replace with your test user's credentials ---
test_user_email = "theageofai1@outlook.com" 
test_user_password = "Test011"
# --- IMPORTANT: Replace with your test user's credentials ---

if not supabase_url or not supabase_key:
    print("Error: SUPABASE_URL or SUPABASE_KEY environment variables not set.")
    print("Please ensure they are correctly set in your .env file.")
    exit()

if test_user_email == "YOUR_TEST_USER_EMAIL@example.com" or test_user_password == "YOUR_TEST_USER_PASSWORD":
    print("Error: Please update the script with your actual test user's email and password.")
    exit()

try:
    print(f"Attempting to connect to Supabase at: {supabase_url}")
    supabase: Client = create_client(supabase_url, supabase_key)
    print("Supabase client created.")

    print(f"Attempting to sign in as: {test_user_email}")
    response = supabase.auth.sign_in_with_password({
        "email": test_user_email,
        "password": test_user_password
    })

    if response.session and response.session.access_token:
        print("\n--- Login Successful! ---")
        print(f"User ID: {response.user.id if response.user else 'N/A'}")
        print("\nAccess Token (JWT):")
        print(response.session.access_token)
        print("\nThis is the token you can use (prefixed with 'Bearer ') in Swagger UI or Postman.")
    else:
        print("\n--- Login Failed ---")
        if response.error:
            print(f"Error: {response.error.message} (Status: {response.error.status})")
        else:
            print("Unknown error during login. Full response:")
            print(response)

except Exception as e:
    print(f"\nAn unexpected error occurred: {e}")
    import traceback
    traceback.print_exc()
