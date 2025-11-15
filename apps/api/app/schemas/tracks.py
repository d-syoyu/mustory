from uuid import UUID

from pydantic import BaseModel

from .comments import CommentSchema
from .story import StorySchema


class TrackSchema(BaseModel):
    id: UUID
    title: str
    artist_name: str
    user_id: UUID
    artwork_url: str
    hls_url: str
    like_count: int
    is_liked: bool = False
    story: StorySchema | None = None


class TrackDetailResponse(BaseModel):
    track: TrackSchema
    track_comments: list[CommentSchema]
    story_comments: list[CommentSchema]
