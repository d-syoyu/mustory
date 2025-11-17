from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel


class CommentSchema(BaseModel):
    id: UUID
    author_user_id: UUID
    author_display_name: str
    body: str
    created_at: datetime
    target_type: Literal["track", "story"]
    target_id: UUID
    parent_comment_id: UUID | None
    like_count: int
    reply_count: int
    is_liked: bool = False


class CommentCreateSchema(BaseModel):
    body: str
    parent_comment_id: UUID | None = None
