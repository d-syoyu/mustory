"""Supabase authentication dependencies."""

from dataclasses import dataclass
from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.supabase import get_supabase_client
from app.db import models
from app.dependencies.database import get_db

security = HTTPBearer(auto_error=False)
optional_security = HTTPBearer(auto_error=False)


@dataclass
class UserContext:
    """User context with ID and display name."""
    id: UUID
    display_name: str
    is_admin: bool = False


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
    db: Annotated[Session, Depends(get_db)],
    request: Request,
) -> UserContext:
    """
    Extract and verify user from Supabase JWT token, then fetch user details from database.

    Raises HTTPException if token is invalid or expired.
    """
    auth_header = request.headers.get("authorization", "<missing>")
    print(f"[auth] Received Authorization header: {auth_header}")
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    supabase = get_supabase_client()

    try:
        # Verify token with Supabase
        user_response = supabase.auth.get_user(token)
        if not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user_id = UUID(user_response.user.id)

        # Fetch user from database
        user = db.get(models.User, user_id)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found in database",
                headers={"WWW-Authenticate": "Bearer"},
            )

        return UserContext(
            id=user.id,
            display_name=user.display_name,
            is_admin=False,  # Can be extended with user.is_admin if needed
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Could not validate credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e


async def get_current_user_id(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)],
) -> UUID:
    """
    Extract and verify user ID from Supabase JWT token (legacy, use get_current_user instead).

    Raises HTTPException if token is invalid or expired.
    """
    token = credentials.credentials
    supabase = get_supabase_client()

    try:
        # Verify token with Supabase
        user_response = supabase.auth.get_user(token)
        if not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return UUID(user_response.user.id)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Could not validate credentials: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e


async def get_current_user_id_optional(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(optional_security)],
) -> UUID | None:
    """
    Extract and verify user ID from Supabase JWT token (optional).

    Returns None if no token is provided or if token is invalid.
    """
    if not credentials:
        return None

    token = credentials.credentials
    supabase = get_supabase_client()

    try:
        # Verify token with Supabase
        user_response = supabase.auth.get_user(token)
        if not user_response.user:
            return None
        return UUID(user_response.user.id)
    except Exception:
        return None


# Type aliases for dependency injection
CurrentUser = Annotated[UserContext, Depends(get_current_user)]
OptionalCurrentUser = Annotated[UUID | None, Depends(get_current_user_id_optional)]
