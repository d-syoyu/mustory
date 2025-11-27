from __future__ import annotations

from datetime import datetime, timedelta
from typing import Iterable
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select, String
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
    UserSummary,
)
from ...services.queue import enqueue_track_processing
from ...services.recommendations import RecommendationService

router = APIRouter(prefix="/tracks", tags=["tracks"])

# Simple TTL cache for recommendations
_recommendation_cache: dict[tuple[UUID | None, int], tuple[list[models.Track], datetime]] = {}
_CACHE_TTL = timedelta(minutes=5)


@router.get("/search", response_model=list[TrackSchema])
def search_tracks(
    q: str = Query(..., min_length=1, description="Search query"),
    db: DbSession = None,
    current_user: OptionalCurrentUser = None,
    limit: int = Query(default=20, ge=1, le=100, description="Number of tracks to return"),
) -> list[TrackSchema]:
    """
    Search tracks by title, artist name, or tags.

    - **q**: Search query (required, min 1 character)
    - **limit**: Maximum number of tracks to return (1-100, default 20)
    - Returns tracks matching the query, ordered by relevance and recency
    """
    search_pattern = f"%{q}%"

    # Search in title, artist_name, and tags
    results = db.execute(
        select(models.Track, models.User)
        .join(models.User, models.Track.user_id == models.User.id)
        .options(selectinload(models.Track.story))
        .where(
            (models.Track.title.ilike(search_pattern)) |
            (models.Track.artist_name.ilike(search_pattern)) |
            (models.Track.tags.cast(String).ilike(search_pattern))
        )
        .order_by(models.Track.created_at.desc())
        .limit(limit)
    ).all()

    tracks_with_users = [(row[0], row[1]) for row in results]
    tracks = [track for track, _ in tracks_with_users]

    # Batch query for user's likes to avoid N+1 problem
    liked_track_ids: set[UUID] = set()
    liked_story_ids: set[UUID] = set()
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

        # Batch query for story likes
        story_ids = [track.story.id for track in tracks if track.story]
        if story_ids:
            liked_stories = db.scalars(
                select(models.LikeStory.story_id).where(
                    models.LikeStory.user_id == current_user,
                    models.LikeStory.story_id.in_(story_ids),
                )
            ).all()
            liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            track.id in liked_track_ids,
            user
        )
        for track, user in tracks_with_users
    ]


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
    results = db.execute(
        select(models.Track, models.User)
        .join(models.User, models.Track.user_id == models.User.id)
        .options(selectinload(models.Track.story))
        .order_by(models.Track.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    tracks_with_users = [(row[0], row[1]) for row in results]
    tracks = [track for track, _ in tracks_with_users]

    # Batch query for user's likes to avoid N+1 problem
    liked_track_ids: set[UUID] = set()
    liked_story_ids: set[UUID] = set()
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

        # Batch query for story likes
        story_ids = [track.story.id for track in tracks if track.story]
        if story_ids:
            liked_stories = db.scalars(
                select(models.LikeStory.story_id).where(
                    models.LikeStory.user_id == current_user,
                    models.LikeStory.story_id.in_(story_ids),
                )
            ).all()
            liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            track.id in liked_track_ids,
            user
        )
        for track, user in tracks_with_users
    ]


@router.get("/liked", response_model=list[TrackSchema])
def list_liked_tracks(
    db: DbSession,
    current_user: CurrentUser,
    limit: int = Query(default=20, ge=1, le=100, description="Number of tracks to return"),
    offset: int = Query(default=0, ge=0, description="Number of tracks to skip"),
) -> list[TrackSchema]:
    """
    List tracks liked by the current user.

    - **limit**: Maximum number of tracks to return (1-100, default 20)
    - **offset**: Number of tracks to skip (default 0)
    - Returns liked tracks ordered by most recently liked first
    """
    # Get liked track IDs for the current user
    liked_track_ids = db.scalars(
        select(models.LikeTrack.track_id)
        .where(models.LikeTrack.user_id == current_user.id)
        .order_by(models.LikeTrack.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    if not liked_track_ids:
        return []

    # Fetch tracks with their stories and user info
    results = db.execute(
        select(models.Track, models.User)
        .join(models.User, models.Track.user_id == models.User.id)
        .options(selectinload(models.Track.story))
        .where(models.Track.id.in_(liked_track_ids))
    ).all()

    # Preserve the order from liked_track_ids
    track_user_dict = {row[0].id: (row[0], row[1]) for row in results}
    ordered_tracks_with_users = [track_user_dict[track_id] for track_id in liked_track_ids if track_id in track_user_dict]
    ordered_tracks = [track for track, _ in ordered_tracks_with_users]

    # All tracks in this endpoint are liked by the current user
    # Batch query for story likes
    liked_story_ids: set[UUID] = set()
    story_ids = [track.story.id for track in ordered_tracks if track.story]
    if story_ids:
        liked_stories = db.scalars(
            select(models.LikeStory.story_id).where(
                models.LikeStory.user_id == current_user.id,
                models.LikeStory.story_id.in_(story_ids),
            )
        ).all()
        liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            True,
            user
        )
        for track, user in ordered_tracks_with_users
    ]


@router.get("/recommendations", response_model=list[TrackSchema])
def get_recommended_tracks(
    db: DbSession,
    current_user: OptionalCurrentUser,
    limit: int = Query(
        default=20,
        ge=1,
        le=50,
        description="Number of personalized tracks to return",
    ),
) -> list[TrackSchema]:
    """
    Return ranked tracks that blend global trending signals with personalized affinity.

    When the listener is not authenticated, this falls back to global popularity/recency.
    """
    # Check cache first
    cache_key = (current_user, limit)
    now = datetime.now()

    if cache_key in _recommendation_cache:
        cached_tracks, cached_time = _recommendation_cache[cache_key]
        if now - cached_time < _CACHE_TTL:
            # Cache hit - use cached results
            recommended_tracks = cached_tracks
        else:
            # Cache expired - remove and fetch new
            del _recommendation_cache[cache_key]
            recommender = RecommendationService(db)
            recommended_tracks = recommender.recommend_tracks(
                user_id=current_user,
                limit=limit,
            )
            _recommendation_cache[cache_key] = (recommended_tracks, now)
    else:
        # Cache miss - fetch and cache
        recommender = RecommendationService(db)
        recommended_tracks = recommender.recommend_tracks(
            user_id=current_user,
            limit=limit,
        )
        _recommendation_cache[cache_key] = (recommended_tracks, now)

    if not recommended_tracks:
        return []

    # Batch fetch user info for all tracks
    track_user_ids = [track.user_id for track in recommended_tracks]
    users = db.scalars(
        select(models.User).where(models.User.id.in_(track_user_ids))
    ).all()
    user_dict = {user.id: user for user in users}

    liked_track_ids: set[UUID] = set()
    if current_user:
        track_ids = [track.id for track in recommended_tracks]
        if track_ids:
            liked_track_ids = set(
                db.scalars(
                    select(models.LikeTrack.track_id).where(
                        models.LikeTrack.user_id == current_user,
                        models.LikeTrack.track_id.in_(track_ids),
                    )
                ).all()
            )

    # Batch query for story likes
    liked_story_ids: set[UUID] = set()
    if current_user:
        story_ids = [track.story.id for track in recommended_tracks if track.story]
        if story_ids:
            liked_stories = db.scalars(
                select(models.LikeStory.story_id).where(
                    models.LikeStory.user_id == current_user,
                    models.LikeStory.story_id.in_(story_ids),
                )
            ).all()
            liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            track.id in liked_track_ids,
            user_dict.get(track.user_id)
        )
        for track in recommended_tracks
    ]


@router.get("/my", response_model=list[TrackSchema])
def list_my_tracks(
    db: DbSession,
    current_user: CurrentUser,
    limit: int = Query(default=20, ge=1, le=100, description="Number of tracks to return"),
    offset: int = Query(default=0, ge=0, description="Number of tracks to skip"),
) -> list[TrackSchema]:
    """
    List tracks uploaded by the current user.

    - **limit**: Maximum number of tracks to return (1-100, default 20)
    - **offset**: Number of tracks to skip (default 0)
    - Returns user's tracks ordered by newest first
    """
    results = db.execute(
        select(models.Track, models.User)
        .join(models.User, models.Track.user_id == models.User.id)
        .options(selectinload(models.Track.story))
        .where(models.Track.user_id == current_user.id)
        .order_by(models.Track.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    tracks_with_users = [(row[0], row[1]) for row in results]
    tracks = [track for track, _ in tracks_with_users]

    # Check which tracks the user has liked
    liked_track_ids: set[UUID] = set()
    liked_story_ids: set[UUID] = set()
    if tracks:
        track_ids = [track.id for track in tracks]
        liked_tracks = db.scalars(
            select(models.LikeTrack.track_id).where(
                models.LikeTrack.user_id == current_user.id,
                models.LikeTrack.track_id.in_(track_ids),
            )
        ).all()
        liked_track_ids = set(liked_tracks)

        # Batch query for story likes
        story_ids = [track.story.id for track in tracks if track.story]
        if story_ids:
            liked_stories = db.scalars(
                select(models.LikeStory.story_id).where(
                    models.LikeStory.user_id == current_user.id,
                    models.LikeStory.story_id.in_(story_ids),
                )
            ).all()
            liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            track.id in liked_track_ids,
            user
        )
        for track, user in tracks_with_users
    ]


@router.patch("/{track_id}", response_model=TrackSchema)
def update_track(
    track_id: UUID,
    title: str | None = None,
    artist_name: str | None = None,
    story_lead: str | None = None,
    story_body: str | None = None,
    db: DbSession = None,
    current_user: CurrentUser = None,
) -> TrackSchema:
    """Update track information (title, artist name, and/or story)."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    # Check if the current user is the owner of the track
    if track.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to update this track.",
        )

    # Update track fields if provided
    if title is not None and title.strip():
        track.title = title.strip()
    if artist_name is not None and artist_name.strip():
        track.artist_name = artist_name.strip()

    # Update or create story if lead or body is provided
    if story_lead is not None or story_body is not None:
        if track.story:
            # Update existing story
            if story_lead is not None:
                track.story.lead = story_lead
            if story_body is not None:
                track.story.body = story_body
        else:
            # Create new story
            story = models.Story(
                track_id=track.id,
                lead=story_lead or "",
                body=story_body or "",
            )
            db.add(story)

    db.commit()
    db.refresh(track)

    story_schema = _map_story(track.story, current_user.id, db) if track.story else None
    return _map_track(track, story_schema, current_user.id, db)


@router.delete("/{track_id}", status_code=status.HTTP_204_NO_CONTENT, response_model=None)
def delete_track(
    track_id: UUID,
    db: DbSession = None,
    current_user: CurrentUser = None,
):
    """Delete a track."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    # Check if the current user is the owner of the track
    if track.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not authorized to delete this track.",
        )

    db.delete(track)
    db.commit()


@router.get("/{track_id}", response_model=TrackDetailResponse)
def get_track_detail(
    track_id: UUID,
    db: DbSession,
    current_user: OptionalCurrentUser,
) -> TrackDetailResponse:
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    story_schema = _map_story(track.story, current_user, db) if track.story else None
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


@router.post("/{track_id}/view", status_code=status.HTTP_200_OK)
def increment_track_view(
    track_id: UUID,
    db: DbSession,
) -> dict:
    """Increment view count when a track is played."""
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    # Increment view_count
    track.view_count += 1
    db.commit()

    return {"message": "View counted successfully.", "view_count": track.view_count}


def _map_track_with_like_status(
    track: models.Track,
    story_schema: StorySchema | None,
    is_liked: bool,
    user: models.User | None = None,
) -> TrackSchema:
    """Map track to schema with pre-computed like status (optimized version)."""
    user_summary = None
    if user:
        user_summary = UserSummary(
            id=user.id,
            username=user.username,
            display_name=user.display_name,
            avatar_url=user.avatar_url,
        )

    return TrackSchema(
        id=track.id,
        title=track.title,
        artist_name=track.artist_name,
        user_id=track.user_id,
        artwork_url=track.artwork_url,
        hls_url=track.hls_url,
        like_count=track.like_count,
        view_count=track.view_count,
        is_liked=is_liked,
        duration_seconds=track.duration_seconds,
        bpm=track.bpm,
        loudness_lufs=track.loudness_lufs,
        mood_valence=track.mood_valence,
        mood_energy=track.mood_energy,
        has_vocals=track.has_vocals,
        tags=track.tags or [],
        story=story_schema,
        user=user_summary,
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

    # Fetch user info
    user = db.get(models.User, track.user_id)
    user_summary = None
    if user:
        user_summary = UserSummary(
            id=user.id,
            username=user.username,
            display_name=user.display_name,
            avatar_url=user.avatar_url,
        )

    return TrackSchema(
        id=track.id,
        title=track.title,
        artist_name=track.artist_name,
        user_id=track.user_id,
        artwork_url=track.artwork_url,
        hls_url=track.hls_url,
        like_count=track.like_count,
        view_count=track.view_count,
        is_liked=is_liked,
        duration_seconds=track.duration_seconds,
        bpm=track.bpm,
        loudness_lufs=track.loudness_lufs,
        mood_valence=track.mood_valence,
        mood_energy=track.mood_energy,
        has_vocals=track.has_vocals,
        tags=track.tags or [],
        story=story_schema,
        user=user_summary,
    )


def _map_story(
    story: models.Story | None,
    current_user: UUID | None = None,
    db: DbSession | None = None,
) -> StorySchema | None:
    if story is None:
        return None

    # Check if current user has liked this story
    is_liked = False
    if current_user and db:
        existing_like = db.scalar(
            select(models.LikeStory).where(
                models.LikeStory.user_id == current_user,
                models.LikeStory.story_id == story.id,
            )
        )
        is_liked = existing_like is not None

    return StorySchema(
        id=story.id,
        track_id=story.track_id,
        author_user_id=story.author_user_id,
        lead=story.lead,
        body=story.body,
        like_count=story.like_count,
        is_liked=is_liked,
        created_at=story.created_at,
    )


def _map_story_with_like_status(
    story: models.Story | None,
    is_liked: bool = False,
) -> StorySchema | None:
    """Map story with pre-computed like status (for batch operations)."""
    if story is None:
        return None

    return StorySchema(
        id=story.id,
        track_id=story.track_id,
        author_user_id=story.author_user_id,
        lead=story.lead,
        body=story.body,
        like_count=story.like_count,
        is_liked=is_liked,
        created_at=story.created_at,
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
        tags=[tag.strip() for tag in (payload.tags or []) if tag.strip()],
    )
    db.add(track)
    db.commit()
    db.refresh(track)

    # Create story if lead or body is provided
    if payload.story_lead or payload.story_body:
        story = models.Story(
            track_id=track.id,
            lead=payload.story_lead or "",
            body=payload.story_body or "",
        )
        db.add(story)
        db.commit()

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
    job_id = enqueue_track_processing(str(track.id))

    # Save job_id to track for progress tracking
    track.job_id = job_id
    db.commit()

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

    # Get progress from Redis job if available
    progress = None
    if track.job_id:
        from ...services.queue import get_job_progress
        progress = get_job_progress(track.job_id)

    return TrackProcessingStatusResponse(
        track_id=track.id,
        status=track.processing_status.value,
        progress=progress,
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
