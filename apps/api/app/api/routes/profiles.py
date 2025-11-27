"""Profile and follow-related API routes."""

from datetime import datetime
import re
import uuid
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel, Field, validator
from sqlalchemy import func, select

from app.core.storage import get_storage_client
from app.db.models import Follow, Story, Track, User
from app.dependencies.database import DbSession
from app.dependencies.supabase_auth import CurrentUser

router = APIRouter(tags=["profiles"])


class UserSummary(BaseModel):
    id: str
    username: str
    display_name: str
    avatar_url: str | None = None
    email: str | None = None

    class Config:
        from_attributes = True


class UserProfile(BaseModel):
    id: str
    username: str
    display_name: str
    email: str
    avatar_url: str | None = None
    bio: str | None = None
    location: str | None = None
    link_url: str | None = None
    track_count: int
    story_count: int
    follower_count: int
    following_count: int
    is_followed_by_me: bool

    class Config:
        from_attributes = True


class PaginatedUsers(BaseModel):
    items: list[UserSummary]
    next_cursor: str | None = None


class FollowResponse(BaseModel):
    success: bool
    follower_count: int


class UserProfileUpdate(BaseModel):
    display_name: str | None = Field(None, max_length=255)
    username: str | None = Field(None, min_length=3, max_length=30)
    bio: str | None = Field(None, max_length=200)
    location: str | None = Field(None, max_length=120)
    link_url: str | None = Field(None, max_length=2048)
    avatar_url: str | None = Field(None, max_length=2048)

    @validator("username")
    def validate_username(cls, v: str | None) -> str | None:
        if v is None:
            return v
        if not re.match(r"^[a-z0-9_]{3,30}$", v):
            raise ValueError("username must be 3-30 chars, lowercase a-z, 0-9, underscore")
        return v


class AvatarPresignRequest(BaseModel):
    file_name: str | None = None
    content_type: str = "image/jpeg"


class AvatarPresignResponse(BaseModel):
    upload_url: str
    object_key: str
    public_url: str


def _validate_cursor(cursor: str | None) -> datetime | None:
    if not cursor:
        return None
    try:
        return datetime.fromisoformat(cursor)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid cursor format, use ISO 8601 datetime",
        )


def _build_user_profile(
    user: User,
    current_user_id: UUID,
    db: DbSession,
) -> UserProfile:
    user_id = user.id

    track_count = (
        db.execute(select(func.count(Track.id)).where(Track.user_id == user_id))
        .scalar()
        or 0
    )
    story_count = (
        db.execute(select(func.count(Story.id)).where(Story.author_user_id == user_id))
        .scalar()
        or 0
    )
    follower_count = (
        db.execute(select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id))
        .scalar()
        or 0
    )
    following_count = (
        db.execute(select(func.count(Follow.followee_id)).where(Follow.follower_id == user_id))
        .scalar()
        or 0
    )
    is_followed_by_me = (
        db.execute(
            select(Follow).where(
                Follow.follower_id == current_user_id,
                Follow.followee_id == user_id,
            )
        ).scalar_one_or_none()
        is not None
    )

    return UserProfile(
        id=str(user.id),
        username=user.username,
        display_name=user.display_name,
        email=user.email,
        avatar_url=user.avatar_url,
        bio=user.bio,
        location=user.location,
        link_url=user.link_url,
        track_count=track_count,
        story_count=story_count,
        follower_count=follower_count,
        following_count=following_count,
        is_followed_by_me=is_followed_by_me,
    )


@router.get("/me/profile", response_model=UserProfile)
async def get_me_profile(
    current_user: CurrentUser,
    db: DbSession,
) -> UserProfile:
    """Get the authenticated user's profile."""
    user = db.get(User, current_user.id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return _build_user_profile(user, current_user.id, db)


@router.put("/me/profile", response_model=UserProfile)
async def update_me_profile(
    payload: UserProfileUpdate,
    current_user: CurrentUser,
    db: DbSession,
) -> UserProfile:
    """Update the authenticated user's profile (partial update)."""
    user = db.get(User, current_user.id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Check username duplication
    if payload.username and payload.username != user.username:
        existing = db.execute(select(User).where(User.username == payload.username)).scalar_one_or_none()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already taken",
            )

    if payload.display_name is not None:
        user.display_name = payload.display_name.strip()
    if payload.username is not None:
        user.username = payload.username
    if payload.bio is not None:
        user.bio = payload.bio.strip() if payload.bio else None
    if payload.location is not None:
        user.location = payload.location.strip() if payload.location else None
    if payload.link_url is not None:
        user.link_url = payload.link_url.strip() if payload.link_url else None
    if payload.avatar_url is not None:
        user.avatar_url = payload.avatar_url.strip() if payload.avatar_url else None

    user.updated_at = datetime.utcnow()
    db.add(user)
    db.commit()
    db.refresh(user)

    return _build_user_profile(user, current_user.id, db)


@router.post("/uploads/avatar/presign", response_model=AvatarPresignResponse)
async def create_avatar_presign_url(
    payload: AvatarPresignRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> AvatarPresignResponse:
    """Generate a presigned URL for uploading avatar images."""
    allowed_content_types = {"image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp"}
    content_type = payload.content_type.lower()
    if content_type not in allowed_content_types:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported content type. Use image/jpeg, image/png, or image/webp.",
        )

    file_ext = allowed_content_types[content_type]
    if payload.file_name and "." in payload.file_name:
        file_ext = f".{payload.file_name.rsplit('.', 1)[-1]}"

    object_key = f"avatars/{current_user.id}/{uuid.uuid4()}{file_ext}"
    storage = get_storage_client()
    upload_url = storage.generate_presigned_upload_url(object_key, content_type=content_type)
    public_url = storage.get_public_url(object_key)

    return AvatarPresignResponse(
        upload_url=upload_url,
        object_key=object_key,
        public_url=public_url,
    )


@router.get("/profiles/search", response_model=list[UserSummary])
async def search_users(
    q: str = Query(..., min_length=1, description="Search query"),
    current_user: CurrentUser = None,
    db: DbSession = None,
    limit: int = Query(default=20, ge=1, le=100, description="Number of users to return"),
) -> list[UserSummary]:
    """
    Search users by username or display name.

    - **q**: Search query (required, min 1 character)
    - **limit**: Maximum number of users to return (1-100, default 20)
    """
    search_pattern = f"%{q}%"

    results = db.execute(
        select(User)
        .where(
            (User.username.ilike(search_pattern)) |
            (User.display_name.ilike(search_pattern))
        )
        .order_by(User.display_name)
        .limit(limit)
    ).scalars().all()

    return [
        UserSummary(
            id=str(user.id),
            username=user.username,
            display_name=user.display_name,
            avatar_url=user.avatar_url,
        )
        for user in results
    ]


@router.get("/profiles/{user_id}", response_model=UserProfile)
async def get_user_profile(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> UserProfile:
    """
    Get a user's profile with statistics and follow status.
    """
    # Get user
    result = db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    return _build_user_profile(user, current_user.id, db)


@router.post("/follows/{user_id}", response_model=FollowResponse)
async def follow_user(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> FollowResponse:
    """
    Follow a user. Idempotent - returns success even if already following.
    """
    if current_user.id == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot follow yourself",
        )

    # Check if target user exists
    result = db.execute(select(User).where(User.id == user_id))
    target_user = result.scalar_one_or_none()

    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Check if already following
    existing_follow_result = db.execute(
        select(Follow).where(
            Follow.follower_id == current_user.id,
            Follow.followee_id == user_id,
        )
    )
    existing_follow = existing_follow_result.scalar_one_or_none()

    if not existing_follow:
        # Create follow relationship
        follow = Follow(follower_id=current_user.id, followee_id=user_id)
        db.add(follow)
        db.commit()

    # Get updated follower count
    follower_count_result = db.execute(
        select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    return FollowResponse(success=True, follower_count=follower_count)


@router.delete("/follows/{user_id}", response_model=FollowResponse)
async def unfollow_user(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> FollowResponse:
    """
    Unfollow a user. Idempotent - returns success even if not following.
    """
    # Delete follow relationship if it exists
    result = db.execute(
        select(Follow).where(
            Follow.follower_id == current_user.id,
            Follow.followee_id == user_id,
        )
    )
    follow = result.scalar_one_or_none()

    if follow:
        db.delete(follow)
        db.commit()

    # Get updated follower count
    follower_count_result = db.execute(
        select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    return FollowResponse(success=True, follower_count=follower_count)


@router.get("/profiles/{user_id}/followers", response_model=PaginatedUsers)
async def get_followers(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    cursor: str | None = Query(None),
) -> PaginatedUsers:
    """
    Get list of users following the specified user (cursor pagination).
    """
    # Check if user exists
    user_result = db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    cursor_dt = _validate_cursor(cursor)

    base_query = (
        select(User, Follow.created_at)
        .join(Follow, Follow.follower_id == User.id)
        .where(Follow.followee_id == user_id)
    )
    if cursor_dt:
        base_query = base_query.where(Follow.created_at < cursor_dt)

    result = db.execute(
        base_query.order_by(Follow.created_at.desc()).limit(limit + 1)
    )
    rows = result.all()
    items = [
        UserSummary(
            id=str(row[0].id),
            username=row[0].username,
            display_name=row[0].display_name,
            avatar_url=row[0].avatar_url,
            email=row[0].email,
        )
        for row in rows[:limit]
    ]
    next_cursor = rows[limit][1].isoformat() if len(rows) > limit else None

    return PaginatedUsers(items=items, next_cursor=next_cursor)


@router.get("/profiles/{user_id}/tracks")
async def get_user_tracks(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Get tracks uploaded by a specific user.
    """
    from app.db.models import Track, LikeTrack, LikeStory
    from sqlalchemy.orm import selectinload
    from app.api.routes.tracks import _map_track_with_like_status, _map_story_with_like_status

    # Check if user exists
    user_result = db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get tracks with user info
    results = db.execute(
        select(Track, User)
        .join(User, Track.user_id == User.id)
        .options(selectinload(Track.story))
        .where(Track.user_id == user_id)
        .order_by(Track.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    tracks_with_users = [(row[0], row[1]) for row in results]
    tracks = [track for track, _ in tracks_with_users]

    # Batch query for user's likes
    liked_track_ids: set[UUID] = set()
    liked_story_ids: set[UUID] = set()
    if tracks:
        track_ids = [track.id for track in tracks]
        liked_tracks = db.scalars(
            select(LikeTrack.track_id).where(
                LikeTrack.user_id == current_user.id,
                LikeTrack.track_id.in_(track_ids),
            )
        ).all()
        liked_track_ids = set(liked_tracks)

        # Batch query for story likes
        story_ids = [track.story.id for track in tracks if track.story]
        if story_ids:
            liked_stories = db.scalars(
                select(LikeStory.story_id).where(
                    LikeStory.user_id == current_user.id,
                    LikeStory.story_id.in_(story_ids),
                )
            ).all()
            liked_story_ids = set(liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in liked_story_ids if track.story else False),
            track.id in liked_track_ids,
            user_info
        )
        for track, user_info in tracks_with_users
    ]


@router.get("/profiles/{user_id}/stories")
async def get_user_stories(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Get stories written by a specific user.
    """
    from app.db.models import Story, Track, LikeStory
    from sqlalchemy.orm import selectinload
    from app.schemas.story import StorySchema

    # Check if user exists
    user_result = db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get stories with track info
    results = db.execute(
        select(Story, Track)
        .join(Track, Story.track_id == Track.id)
        .where(Story.author_user_id == user_id)
        .order_by(Story.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    stories_with_tracks = [(row[0], row[1]) for row in results]
    stories = [story for story, _ in stories_with_tracks]

    # Batch query for user's story likes
    liked_story_ids: set[UUID] = set()
    if stories:
        story_ids = [story.id for story in stories]
        liked_stories = db.scalars(
            select(LikeStory.story_id).where(
                LikeStory.user_id == current_user.id,
                LikeStory.story_id.in_(story_ids),
            )
        ).all()
        liked_story_ids = set(liked_stories)

    return [
        StorySchema(
            id=story.id,
            track_id=story.track_id,
            author_user_id=story.author_user_id,
            lead=story.lead,
            body=story.body,
            like_count=story.like_count,
            is_liked=story.id in liked_story_ids,
            created_at=story.created_at,
        )
        for story, _ in stories_with_tracks
    ]


@router.get("/profiles/{user_id}/liked-tracks")
async def get_user_liked_tracks(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    offset: int = Query(0, ge=0),
):
    """
    Get tracks liked by a specific user.
    Note: Currently returns liked tracks for any user.
    In production, you may want to restrict this to the current user only.
    """
    from app.db.models import Track, LikeTrack, LikeStory
    from sqlalchemy.orm import selectinload
    from app.api.routes.tracks import _map_track_with_like_status, _map_story_with_like_status

    # Check if user exists
    user_result = db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get liked track IDs for the user
    liked_track_ids_result = db.scalars(
        select(LikeTrack.track_id)
        .where(LikeTrack.user_id == user_id)
        .order_by(LikeTrack.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    if not liked_track_ids_result:
        return []

    # Fetch tracks with their stories and user info
    results = db.execute(
        select(Track, User)
        .join(User, Track.user_id == User.id)
        .options(selectinload(Track.story))
        .where(Track.id.in_(liked_track_ids_result))
    ).all()

    # Preserve the order from liked_track_ids
    track_user_dict = {row[0].id: (row[0], row[1]) for row in results}
    ordered_tracks_with_users = [track_user_dict[track_id] for track_id in liked_track_ids_result if track_id in track_user_dict]
    ordered_tracks = [track for track, _ in ordered_tracks_with_users]

    # Batch query for current user's likes (to show if current user also liked these tracks)
    current_user_liked_track_ids: set[UUID] = set()
    current_user_liked_story_ids: set[UUID] = set()
    if ordered_tracks:
        track_ids = [track.id for track in ordered_tracks]
        current_user_liked_tracks = db.scalars(
            select(LikeTrack.track_id).where(
                LikeTrack.user_id == current_user.id,
                LikeTrack.track_id.in_(track_ids),
            )
        ).all()
        current_user_liked_track_ids = set(current_user_liked_tracks)

        # Batch query for story likes
        story_ids = [track.story.id for track in ordered_tracks if track.story]
        if story_ids:
            current_user_liked_stories = db.scalars(
                select(LikeStory.story_id).where(
                    LikeStory.user_id == current_user.id,
                    LikeStory.story_id.in_(story_ids),
                )
            ).all()
            current_user_liked_story_ids = set(current_user_liked_stories)

    return [
        _map_track_with_like_status(
            track,
            _map_story_with_like_status(track.story, track.story.id in current_user_liked_story_ids if track.story else False),
            track.id in current_user_liked_track_ids,
            user_info
        )
        for track, user_info in ordered_tracks_with_users
    ]


@router.get("/profiles/{user_id}/following", response_model=PaginatedUsers)
async def get_following(
    user_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    cursor: str | None = Query(None),
) -> PaginatedUsers:
    """
    Get list of users that the specified user is following (cursor pagination).
    """
    # Check if user exists
    user_result = db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    cursor_dt = _validate_cursor(cursor)

    base_query = (
        select(User, Follow.created_at)
        .join(Follow, Follow.followee_id == User.id)
        .where(Follow.follower_id == user_id)
    )
    if cursor_dt:
        base_query = base_query.where(Follow.created_at < cursor_dt)

    result = db.execute(
        base_query.order_by(Follow.created_at.desc()).limit(limit + 1)
    )
    rows = result.all()
    items = [
        UserSummary(
            id=str(row[0].id),
            username=row[0].username,
            display_name=row[0].display_name,
            avatar_url=row[0].avatar_url,
            email=row[0].email,
        )
        for row in rows[:limit]
    ]
    next_cursor = rows[limit][1].isoformat() if len(rows) > limit else None

    return PaginatedUsers(items=items, next_cursor=next_cursor)