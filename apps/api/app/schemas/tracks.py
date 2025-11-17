from uuid import UUID

from pydantic import BaseModel, Field

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


class TrackUploadInitRequest(BaseModel):
    """Request to initiate track upload."""

    title: str = Field(..., min_length=1, max_length=255, description="Track title")
    artist_name: str = Field(
        ..., min_length=1, max_length=255, description="Artist name"
    )
    file_extension: str = Field(
        ..., pattern=r"^(mp3|m4a|wav|flac|ogg)$", description="Audio file extension"
    )
    file_size: int = Field(..., gt=0, lt=500 * 1024 * 1024, description="File size in bytes (max 500MB)")
    artwork_extension: str | None = Field(
        None, pattern=r"^(jpg|jpeg|png|webp)$", description="Artwork file extension"
    )


class TrackUploadInitResponse(BaseModel):
    """Response for track upload initiation."""

    track_id: UUID
    audio_upload_url: str  # Presigned PUT URL
    artwork_upload_url: str | None = None  # Presigned PUT URL


class TrackUploadCompleteRequest(BaseModel):
    """Request to mark track upload as complete."""

    track_id: UUID


class TrackProcessingStatusResponse(BaseModel):
    """Track processing status response."""

    track_id: UUID
    status: str  # pending, processing, completed, failed
    progress: int | None = Field(None, ge=0, le=100, description="Processing progress percentage")
    error: str | None = None
