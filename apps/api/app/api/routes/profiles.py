"""
Profile and follow-related API routes.
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Follow, Story, Track, User
from app.db.session import get_db
from app.dependencies.supabase_auth import CurrentUser

router = APIRouter(tags=["profiles"])


class UserSummary(BaseModel):
    id: str
    display_name: str
    email: str | None = None

    class Config:
        from_attributes = True


class UserProfile(BaseModel):
    id: str
    display_name: str
    email: str
    track_count: int
    story_count: int
    follower_count: int
    following_count: int
    is_followed_by_me: bool

    class Config:
        from_attributes = True


class FollowResponse(BaseModel):
    success: bool
    follower_count: int


@router.get("/profiles/{user_id}", response_model=UserProfile)
async def get_user_profile(
    user_id: UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> UserProfile:
    """
    Get a user's profile with statistics and follow status.
    """
    # Get user
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Count tracks
    track_count_result = await db.execute(
        select(func.count(Track.id)).where(Track.user_id == user_id)
    )
    track_count = track_count_result.scalar() or 0

    # Count stories
    story_count_result = await db.execute(
        select(func.count(Story.id)).where(Story.author_user_id == user_id)
    )
    story_count = story_count_result.scalar() or 0

    # Count followers
    follower_count_result = await db.execute(
        select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    # Count following
    following_count_result = await db.execute(
        select(func.count(Follow.followee_id)).where(Follow.follower_id == user_id)
    )
    following_count = following_count_result.scalar() or 0

    # Check if current user follows this user
    is_followed_result = await db.execute(
        select(Follow).where(
            Follow.follower_id == current_user,
            Follow.followee_id == user_id,
        )
    )
    is_followed_by_me = is_followed_result.scalar_one_or_none() is not None

    return UserProfile(
        id=str(user.id),
        display_name=user.display_name,
        email=user.email,
        track_count=track_count,
        story_count=story_count,
        follower_count=follower_count,
        following_count=following_count,
        is_followed_by_me=is_followed_by_me,
    )


@router.post("/follows/{user_id}", response_model=FollowResponse)
async def follow_user(
    user_id: UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> FollowResponse:
    """
    Follow a user. Idempotent - returns success even if already following.
    """
    if current_user == user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot follow yourself",
        )

    # Check if target user exists
    result = await db.execute(select(User).where(User.id == user_id))
    target_user = result.scalar_one_or_none()

    if not target_user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Check if already following
    existing_follow_result = await db.execute(
        select(Follow).where(
            Follow.follower_id == current_user,
            Follow.followee_id == user_id,
        )
    )
    existing_follow = existing_follow_result.scalar_one_or_none()

    if not existing_follow:
        # Create follow relationship
        follow = Follow(follower_id=current_user, followee_id=user_id)
        db.add(follow)
        await db.commit()

    # Get updated follower count
    follower_count_result = await db.execute(
        select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    return FollowResponse(success=True, follower_count=follower_count)


@router.delete("/follows/{user_id}", response_model=FollowResponse)
async def unfollow_user(
    user_id: UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
) -> FollowResponse:
    """
    Unfollow a user. Idempotent - returns success even if not following.
    """
    # Delete follow relationship if it exists
    result = await db.execute(
        select(Follow).where(
            Follow.follower_id == current_user,
            Follow.followee_id == user_id,
        )
    )
    follow = result.scalar_one_or_none()

    if follow:
        await db.delete(follow)
        await db.commit()

    # Get updated follower count
    follower_count_result = await db.execute(
        select(func.count(Follow.follower_id)).where(Follow.followee_id == user_id)
    )
    follower_count = follower_count_result.scalar() or 0

    return FollowResponse(success=True, follower_count=follower_count)


@router.get("/profiles/{user_id}/followers", response_model=list[UserSummary])
async def get_followers(
    user_id: UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
) -> list[UserSummary]:
    """
    Get list of users following the specified user.
    """
    # Check if user exists
    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get followers
    result = await db.execute(
        select(User)
        .join(Follow, Follow.follower_id == User.id)
        .where(Follow.followee_id == user_id)
        .order_by(Follow.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    followers = result.scalars().all()

    return [
        UserSummary(
            id=str(follower.id),
            display_name=follower.display_name,
            email=follower.email,
        )
        for follower in followers
    ]


@router.get("/profiles/{user_id}/following", response_model=list[UserSummary])
async def get_following(
    user_id: UUID,
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
) -> list[UserSummary]:
    """
    Get list of users that the specified user is following.
    """
    # Check if user exists
    user_result = await db.execute(select(User).where(User.id == user_id))
    user = user_result.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )

    # Get following
    result = await db.execute(
        select(User)
        .join(Follow, Follow.followee_id == User.id)
        .where(Follow.follower_id == user_id)
        .order_by(Follow.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    following = result.scalars().all()

    return [
        UserSummary(
            id=str(user.id),
            display_name=user.display_name,
            email=user.email,
        )
        for user in following
    ]
