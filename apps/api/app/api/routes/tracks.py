from __future__ import annotations

from typing import Iterable
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import selectinload

from ...core.storage import get_storage_client
from ...db import models
from ...dependencies.supabase_auth import CurrentUser, OptionalCurrentUser
from ...dependencies.database import DbSession
from ...schemas.comments import CommentCreateSchema, CommentSchema
from ...schemas.story import StorySchema
from ...schemas.tracks import (
    TrackDetailResponse,
    TrackSchema,
    TrackUploadInitRequest,
    TrackUploadInitResponse,
    TrackUploadCompleteRequest,
    TrackProcessingStatusResponse,
)
from ...services.queue import enqueue_track_processing

router = APIRouter(prefix="/tracks", tags=["tracks"])


@router.get("/", response_model=list[TrackSchema])
def list_tracks(
    db: DbSession,
    current_user: OptionalCurrentUser,
    limit: int = Query(default=20, ge=1, le=100, description="Number of tracks to return"),
    offset: int = Query(default=0, ge=0, description="Number of tracks to skip"),
) -> list[TrackSchema]:
    """
    List all tracks with pagination.

    - **limit**: Maximum number of tracks to return (1-100, default 20)
    - **offset**: Number of tracks to skip (default 0)
    - Returns tracks ordered by newest first
    """
    tracks = db.scalars(
        select(models.Track)
        .options(selectinload(models.Track.story))
        .order_by(models.Track.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    # Batch query for user's likes to avoid N+1 problem
    liked_track_ids: set[UUID] = set()
    if current_user:
        track_ids = [track.id for track in tracks]
        if track_ids:
            liked_tracks = db.scalars(
                select(models.LikeTrack.track_id).where(
                    models.LikeTrack.user_id == current_user,
                    models.LikeTrack.track_id.in_(track_ids),
                )
            ).all()
            liked_track_ids = set(liked_tracks)

    return [
        _map_track_with_like_status(track, _map_story(track.story), track.id in liked_track_ids)
        for track in tracks
    ]


@router.get("/{track_id}", response_model=TrackDetailResponse)
def get_track_detail(
    track_id: UUID,
    db: DbSession,
    current_user: OptionalCurrentUser,
) -> TrackDetailResponse:
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    story_schema = _map_story(track.story) if track.story else None
    track_comments_rows = list(
        db.scalars(
            select(models.Comment)
            .where(
                models.Comment.target_type == models.CommentTargetType.TRACK,
                models.Comment.target_id == track_id,
                models.Comment.is_deleted.is_(False),
            )
            .order_by(models.Comment.created_at.desc())
        )
    )
    track_comments = _map_comments(track_comments_rows, current_user, db)

    story_comments: list[CommentSchema] = []
    if track.story:
        story_comments_rows = list(
            db.scalars(
                select(models.Comment)
                    .where(
                        models.Comment.target_type == models.CommentTargetType.STORY,
                        models.Comment.target_id == track.story.id,
                        models.Comment.is_deleted.is_(False),
                    )
                    .order_by(models.Comment.created_at.desc())
            )
        )
        story_comments = _map_comments(story_comments_rows, current_user, db)

    return TrackDetailResponse(
        track=_map_track(track, story_schema, current_user, db),
        track_comments=track_comments,
        story_comments=story_comments,
    )


@router.get("/{track_id}/comments", response_model=list[CommentSchema])
def list_track_comments(
    track_id: UUID,
    db: DbSession,
    current_user: OptionalCurrentUser,
) -> list[CommentSchema]:
    comments_rows = list(
        db.scalars(
            select(models.Comment)
            .where(
                models.Comment.target_type == models.CommentTargetType.TRACK,
                models.Comment.target_id == track_id,
                models.Comment.is_deleted.is_(False),
            )
            .order_by(models.Comment.created_at.desc())
        )
    )
    return _map_comments(comments_rows, current_user, db)


@router.post(
    "/{track_id}/comments",
    response_model=CommentSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_track_comment(
    track_id: UUID,
    payload: CommentCreateSchema,
    db: DbSession,
    current_user: CurrentUser,
) -> CommentSchema:
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")
    if not payload.body.strip():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Empty comment.")

    # If this is a reply to another comment, validate parent comment exists
    if payload.parent_comment_id:
        parent_comment = db.get(models.Comment, payload.parent_comment_id)
        if not parent_comment or parent_comment.is_deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Parent comment not found.",
            )
        # Verify parent comment is for the same track
        if parent_comment.target_type != models.CommentTargetType.TRACK or parent_comment.target_id != track_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Parent comment does not belong to this track.",
            )

    comment = models.Comment(
        author_user_id=current_user.id,
        author_display_name=current_user.display_name,
        body=payload.body.strip(),
        target_type=models.CommentTargetType.TRACK,
        target_id=track_id,
        parent_comment_id=payload.parent_comment_id,
    )
    db.add(comment)

    # Increment parent comment's reply_count if this is a reply
    if payload.parent_comment_id:
        parent_comment.reply_count += 1

    db.commit()
    db.refresh(comment)
    return _map_comment(comment, current_user.id, db)


@router.post("/{track_id}/like", status_code=status.HTTP_201_CREATED)
def like_track(
    track_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Like a track."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    # Check if already liked
    existing_like = db.scalar(
        select(models.LikeTrack).where(
            models.LikeTrack.user_id == current_user.id,
            models.LikeTrack.track_id == track_id,
        )
    )
    if existing_like:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Track already liked.",
        )

    # Create like
    like = models.LikeTrack(user_id=current_user.id, track_id=track_id)
    db.add(like)

    # Increment like_count
    track.like_count += 1

    db.commit()
    return {"message": "Track liked successfully."}


@router.delete("/{track_id}/like", status_code=status.HTTP_200_OK)
def unlike_track(
    track_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Unlike a track."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    # Find existing like
    like = db.scalar(
        select(models.LikeTrack).where(
            models.LikeTrack.user_id == current_user.id,
            models.LikeTrack.track_id == track_id,
        )
    )
    if not like:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Like not found.",
        )

    # Delete like
    db.delete(like)

    # Decrement like_count
    if track.like_count > 0:
        track.like_count -= 1

    db.commit()
    return {"message": "Track unliked successfully."}


def _map_track_with_like_status(
    track: models.Track,
    story_schema: StorySchema | None,
    is_liked: bool,
) -> TrackSchema:
    """Map track to schema with pre-computed like status (optimized version)."""
    return TrackSchema(
        id=track.id,
        title=track.title,
        artist_name=track.artist_name,
        user_id=track.user_id,
        artwork_url=track.artwork_url,
        hls_url=track.hls_url,
        like_count=track.like_count,
        is_liked=is_liked,
        story=story_schema,
    )


def _map_track(
    track: models.Track,
    story_schema: StorySchema | None,
    current_user: UUID | None,
    db: DbSession,
) -> TrackSchema:
    """Map track to schema with database lookup for like status (legacy version)."""
    is_liked = False
    if current_user:
        # Check if the current user has liked this track
        existing_like = db.scalar(
            select(models.LikeTrack).where(
                models.LikeTrack.user_id == current_user,
                models.LikeTrack.track_id == track.id,
            )
        )
        is_liked = existing_like is not None

    return TrackSchema(
        id=track.id,
        title=track.title,
        artist_name=track.artist_name,
        user_id=track.user_id,
        artwork_url=track.artwork_url,
        hls_url=track.hls_url,
        like_count=track.like_count,
        is_liked=is_liked,
        story=story_schema,
    )


def _map_story(story: models.Story | None) -> StorySchema | None:
    if story is None:
        return None
    return StorySchema(
        id=story.id,
        track_id=story.track_id,
        author_user_id=story.author_user_id,
        lead=story.lead,
        body=story.body,
        like_count=story.like_count,
    )


def _map_comments(
    rows: Iterable[models.Comment],
    current_user: UUID | None,
    db: DbSession,
) -> list[CommentSchema]:
    comments = list(rows)
    if not comments:
        return []

    # Batch query for user's liked comments to avoid N+1 problem
    liked_comment_ids: set[UUID] = set()
    if current_user:
        comment_ids = [comment.id for comment in comments]
        if comment_ids:
            liked_comments = db.scalars(
                select(models.LikeComment.comment_id).where(
                    models.LikeComment.user_id == current_user,
                    models.LikeComment.comment_id.in_(comment_ids),
                )
            ).all()
            liked_comment_ids = set(liked_comments)

    return [
        _map_comment(comment, current_user, db, comment.id in liked_comment_ids)
        for comment in comments
    ]


def _map_comment(
    comment: models.Comment,
    current_user: UUID | None,
    db: DbSession,
    is_liked: bool | None = None,
) -> CommentSchema:
    # If is_liked is not provided (single comment mapping), check directly
    if is_liked is None:
        is_liked = False
        if current_user:
            existing_like = db.scalar(
                select(models.LikeComment).where(
                    models.LikeComment.user_id == current_user,
                    models.LikeComment.comment_id == comment.id,
                )
            )
            is_liked = existing_like is not None

    return CommentSchema(
        id=comment.id,
        author_user_id=comment.author_user_id,
        author_display_name=comment.author_display_name,
        body=comment.body,
        created_at=comment.created_at,
        target_type=comment.target_type.value,
        target_id=comment.target_id,
        parent_comment_id=comment.parent_comment_id,
        like_count=comment.like_count,
        reply_count=comment.reply_count,
        is_liked=is_liked,
    )


# ========== Upload Endpoints ==========


@router.post("/upload/init", response_model=TrackUploadInitResponse, status_code=status.HTTP_201_CREATED)
def init_track_upload(
    payload: TrackUploadInitRequest,
    db: DbSession,
    current_user: CurrentUser,
) -> TrackUploadInitResponse:
    """
    Initialize track upload and get presigned URLs for uploading files.

    This creates a Track record in PENDING status and returns presigned URLs
    for uploading the audio file and optional artwork to S3-compatible storage.
    """
    storage = get_storage_client()

    # Create track record in database
    track = models.Track(
        title=payload.title,
        artist_name=payload.artist_name,
        user_id=current_user.id,
        artwork_url="",  # Will be updated after upload
        hls_url="",  # Will be set after FFmpeg processing
        processing_status=models.TrackProcessingStatus.PENDING,
    )
    db.add(track)
    db.commit()
    db.refresh(track)

    # Generate S3 object keys
    audio_key = f"tracks/{track.id}/original.{payload.file_extension}"

    # Generate presigned PUT URL for audio upload
    audio_presigned_url = storage.generate_presigned_upload_url(
        object_key=audio_key,
        content_type=_get_audio_mime_type(payload.file_extension),
        expires_in=3600,  # 1 hour
    )

    # Update track with original audio URL
    track.original_audio_url = storage.get_public_url(audio_key)

    # Generate presigned PUT URL for artwork if provided
    artwork_presigned_url = None
    if payload.artwork_extension:
        artwork_key = f"tracks/{track.id}/artwork.{payload.artwork_extension}"
        artwork_presigned_url = storage.generate_presigned_upload_url(
            object_key=artwork_key,
            content_type=_get_image_mime_type(payload.artwork_extension),
            expires_in=3600,
        )
        track.artwork_url = storage.get_public_url(artwork_key)
    else:
        # Use default artwork
        track.artwork_url = "https://via.placeholder.com/400x400?text=No+Artwork"

    db.commit()

    return TrackUploadInitResponse(
        track_id=track.id,
        audio_upload_url=audio_presigned_url,
        artwork_upload_url=artwork_presigned_url,
    )


@router.post("/upload/complete", status_code=status.HTTP_200_OK)
def complete_track_upload(
    payload: TrackUploadCompleteRequest,
    db: DbSession,
    current_user: CurrentUser,
) -> dict[str, str]:
    """
    Mark track upload as complete and trigger FFmpeg processing.

    This endpoint should be called after the client has successfully uploaded
    the audio file to S3. It will enqueue the track for FFmpeg HLS conversion.
    """
    track = db.get(models.Track, payload.track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    if track.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized.")

    if track.processing_status != models.TrackProcessingStatus.PENDING:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Track is already {track.processing_status}.",
        )

    # Enqueue FFmpeg processing job to Redis/RQ
    enqueue_track_processing(str(track.id))

    return {"message": "Track upload completed, processing started."}


@router.get("/upload/status/{track_id}", response_model=TrackProcessingStatusResponse)
def get_track_processing_status(
    track_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> TrackProcessingStatusResponse:
    """Get the processing status of an uploaded track."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    if track.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized.")

    return TrackProcessingStatusResponse(
        track_id=track.id,
        status=track.processing_status.value,
        progress=None,  # TODO: Get from Redis job status
        error=track.processing_error,
    )


def _get_audio_mime_type(extension: str) -> str:
    """Get MIME type for audio file extension."""
    mime_types = {
        "mp3": "audio/mpeg",
        "m4a": "audio/mp4",
        "wav": "audio/wav",
        "flac": "audio/flac",
        "ogg": "audio/ogg",
    }
    return mime_types.get(extension, "audio/mpeg")


def _get_image_mime_type(extension: str) -> str:
    """Get MIME type for image file extension."""
    mime_types = {
        "jpg": "image/jpeg",
        "jpeg": "image/jpeg",
        "png": "image/png",
        "webp": "image/webp",
    }
    return mime_types.get(extension, "image/jpeg")
