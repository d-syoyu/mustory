from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class StorySchema(BaseModel):
    id: UUID
    track_id: UUID
    author_user_id: UUID
    lead: str
    body: str
    like_count: int
    is_liked: bool = False
    created_at: datetime


class StoryCreateSchema(BaseModel):
    lead: str
    body: str


class StoryUpdateSchema(BaseModel):
    lead: str | None = None
    body: str | None = None
