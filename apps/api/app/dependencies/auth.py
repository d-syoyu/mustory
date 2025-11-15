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
    """Stubbed auth dependency. Replace with Supabase integration."""
    return UserContext(
        id=UUID("00000000-0000-0000-0000-000000000001"),
        display_name="Demo User",
    )


CurrentUser = Annotated[UserContext, Depends(get_current_user)]
