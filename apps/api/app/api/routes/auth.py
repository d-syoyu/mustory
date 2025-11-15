"""
Supabase authentication routes.

These endpoints are primarily for documentation and testing.
In production, mobile apps should authenticate directly with Supabase client SDK.
"""

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr

from app.core.supabase import get_supabase_client
from app.dependencies.supabase_auth import CurrentUser

router = APIRouter(prefix="/auth", tags=["auth"])


class SignupRequest(BaseModel):
    email: EmailStr
    password: str
    display_name: str | None = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str


@router.post("/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
async def signup(request: SignupRequest) -> TokenResponse:
    """
    Sign up a new user with Supabase Auth.

    Note: In production mobile apps, use Supabase client SDK directly.
    This endpoint is primarily for testing and web client integration.
    """
    supabase = get_supabase_client()

    try:
        # Sign up user with Supabase
        response = supabase.auth.sign_up(
            {
                "email": request.email,
                "password": request.password,
                "options": {
                    "data": {"display_name": request.display_name or request.email.split("@")[0]}
                },
            }
        )

        if not response.user or not response.session:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Failed to create user. Email may already be in use.",
            )

        return TokenResponse(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            user_id=response.user.id,
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Signup failed: {str(e)}",
        ) from e


@router.post("/login", response_model=TokenResponse)
async def login(request: LoginRequest) -> TokenResponse:
    """
    Log in with email and password.

    Note: In production mobile apps, use Supabase client SDK directly.
    This endpoint is primarily for testing and web client integration.
    """
    supabase = get_supabase_client()

    try:
        response = supabase.auth.sign_in_with_password(
            {"email": request.email, "password": request.password}
        )

        if not response.user or not response.session:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
            )

        return TokenResponse(
            access_token=response.session.access_token,
            refresh_token=response.session.refresh_token,
            user_id=response.user.id,
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Login failed: {str(e)}",
        ) from e


@router.post("/logout")
async def logout(current_user: CurrentUser) -> dict[str, str]:
    """
    Log out the current user (invalidate session).

    Note: In production mobile apps, use Supabase client SDK's signOut() directly.
    """
    supabase = get_supabase_client()

    try:
        supabase.auth.sign_out()
        return {"message": "Successfully logged out"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Logout failed: {str(e)}",
        ) from e


@router.get("/me")
async def get_current_user(current_user: CurrentUser) -> dict[str, str]:
    """
    Get current authenticated user information.

    Returns the user ID extracted from the JWT token.
    """
    return {"user_id": str(current_user)}
