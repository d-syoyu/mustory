"""
Test Supabase authentication directly without HTTP server.
"""
import asyncio
from uuid import uuid4

from app.core.supabase import get_supabase_client


async def test_signup():
    """Test user signup with Supabase."""
    supabase = get_supabase_client()

    # Generate unique email with valid domain
    test_email = f"testuser+{uuid4().hex[:8]}@gmail.com"
    test_password = "securepass123"
    test_display_name = "Test User"

    print(f"\nTesting signup with email: {test_email}")

    try:
        response = supabase.auth.sign_up({
            "email": test_email,
            "password": test_password,
            "options": {
                "data": {"display_name": test_display_name}
            }
        })

        print(f"Response user: {response.user}")
        print(f"Response session: {response.session}")

        if response.user and response.session:
            print(f" Signup successful!")
            print(f"   User ID: {response.user.id}")
            print(f"   Email: {response.user.email}")
            print(f"   Access Token: {response.session.access_token[:50]}...")
            print(f"   Refresh Token: {response.session.refresh_token[:50]}...")
            return response
        elif response.user and not response.session:
            print(f" Signup successful but email confirmation required")
            print(f"   User ID: {response.user.id}")
            print(f"   Email: {response.user.email}")
            print(f"   Email confirmed: {response.user.email_confirmed_at}")
            return response
        else:
            print(f" Signup failed: No user or session returned")
            print(f"Full response: {response}")
            return None

    except Exception as e:
        print(f" Signup error: {e}")
        return None


async def test_login(email: str, password: str):
    """Test user login with Supabase."""
    supabase = get_supabase_client()

    print(f"\n Testing login with email: {email}")

    try:
        response = supabase.auth.sign_in_with_password({
            "email": email,
            "password": password
        })

        if response.user and response.session:
            print(f" Login successful!")
            print(f"   User ID: {response.user.id}")
            print(f"   Access Token: {response.session.access_token[:50]}...")
            return response
        else:
            print(f" Login failed: No user or session returned")
            return None

    except Exception as e:
        print(f" Login error: {e}")
        return None


async def test_get_user(access_token: str):
    """Test getting current user with access token."""
    supabase = get_supabase_client()

    print(f"\n Testing get user with token")

    try:
        user_response = supabase.auth.get_user(access_token)

        if user_response.user:
            print(f" Get user successful!")
            print(f"   User ID: {user_response.user.id}")
            print(f"   Email: {user_response.user.email}")
            print(f"   Metadata: {user_response.user.user_metadata}")
            return user_response
        else:
            print(f" Get user failed: No user returned")
            return None

    except Exception as e:
        print(f" Get user error: {e}")
        return None


async def main():
    """Run all authentication tests."""
    print("=" * 60)
    print("Supabase Authentication Test")
    print("=" * 60)

    # Test 1: Signup
    signup_response = await test_signup()
    if not signup_response:
        print("\nSignup test failed. Stopping.")
        return

    test_email = signup_response.user.email

    # Check if email confirmation is required
    if signup_response.session:
        access_token = signup_response.session.access_token

        # Test 2: Get user with token
        await test_get_user(access_token)

        # Test 3: Login with same credentials
        await test_login(test_email, "securepass123")
    else:
        print("\nEmail confirmation is enabled in Supabase.")
        print("To disable for testing:")
        print("1. Go to Supabase Dashboard -> Authentication -> Settings")
        print("2. Disable 'Enable email confirmations'")
        print("\nAlternatively, check Supabase Dashboard -> Authentication -> Users")
        print(f"to see the registered user: {test_email}")

    print("\n" + "=" * 60)
    print("All tests completed!")
    print("=" * 60)
    print(f"\nYou can view the user in Supabase Dashboard:")
    print(f"   https://app.supabase.com/project/_/auth/users")


if __name__ == "__main__":
    asyncio.run(main())
