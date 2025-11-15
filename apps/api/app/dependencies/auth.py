"""
Authentication dependencies.

For Supabase-based authentication, use:
    from app.dependencies.supabase_auth import CurrentUser, get_current_user_id

For demo/testing purposes, this file provides a stub implementation.
"""

from dataclasses import dataclass
from typing import Annotated
from uuid import UUID

from fastapi import Depends


@dataclass
class UserContext:
    id: UUID
    display_name: str
    is_admin: bool = False


def get_current_user() -> UserContext:
    """
    Stub auth dependency for testing/demo.

    In production, replace with Supabase authentication:
        from app.dependencies.supabase_auth import get_current_user_id
    """
    return UserContext(
        id=UUID("00000000-0000-0000-0000-000000000001"),
        display_name="Demo User",
    )


CurrentUser = Annotated[UserContext, Depends(get_current_user)]
