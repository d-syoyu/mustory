"""
Feed API routes for follow-based content discovery.
"""

from datetime import datetime
from typing import Literal

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy import select, union_all
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Follow, Story, Track, User
from app.db.session import get_db
from app.dependencies.supabase_auth import CurrentUser

router = APIRouter(prefix="/feed", tags=["feed"])


class UserInfo(BaseModel):
    id: str
    display_name: str

    class Config:
        from_attributes = True


class TrackInfo(BaseModel):
    id: str
    title: str
    artist_name: str
    artwork_url: str
    hls_url: str
    like_count: int
    view_count: int

    class Config:
        from_attributes = True


class StoryInfo(BaseModel):
    id: str
    track_id: str
    lead: str
    body: str
    like_count: int

    class Config:
        from_attributes = True


class FeedItem(BaseModel):
    type: Literal["track", "story"]
    created_at: datetime
    user: UserInfo
    track: TrackInfo | None = None
    story: StoryInfo | None = None

    class Config:
        from_attributes = True


@router.get("/following", response_model=list[FeedItem])
async def get_following_feed(
    current_user: CurrentUser,
    db: AsyncSession = Depends(get_db),
    limit: int = 50,
    offset: int = 0,
) -> list[FeedItem]:
    """
    Get feed of tracks and stories from users the current user follows.
    Returns items sorted by creation time (newest first).
    """
    # Get list of followed user IDs
    followed_users_result = await db.execute(
        select(Follow.followee_id).where(Follow.follower_id == current_user)
    )
    followed_user_ids = [row[0] for row in followed_users_result.all()]

    if not followed_user_ids:
        return []

    # Get tracks from followed users
    tracks_result = await db.execute(
        select(Track, User)
        .join(User, Track.user_id == User.id)
        .where(Track.user_id.in_(followed_user_ids))
        .order_by(Track.created_at.desc())
        .limit(limit)
    )
    tracks = tracks_result.all()

    # Get stories from followed users
    stories_result = await db.execute(
        select(Story, User, Track)
        .join(User, Story.author_user_id == User.id)
        .join(Track, Story.track_id == Track.id)
        .where(Story.author_user_id.in_(followed_user_ids))
        .order_by(Story.created_at.desc())
        .limit(limit)
    )
    stories = stories_result.all()

    # Combine and sort by created_at
    feed_items: list[FeedItem] = []

    for track, user in tracks:
        feed_items.append(
            FeedItem(
                type="track",
                created_at=track.created_at,
                user=UserInfo(id=str(user.id), display_name=user.display_name),
                track=TrackInfo(
                    id=str(track.id),
                    title=track.title,
                    artist_name=track.artist_name,
                    artwork_url=track.artwork_url,
                    hls_url=track.hls_url,
                    like_count=track.like_count,
                    view_count=track.view_count,
                ),
            )
        )

    for story, user, track in stories:
        feed_items.append(
            FeedItem(
                type="story",
                created_at=story.created_at,
                user=UserInfo(id=str(user.id), display_name=user.display_name),
                story=StoryInfo(
                    id=str(story.id),
                    track_id=str(story.track_id),
                    lead=story.lead,
                    body=story.body,
                    like_count=story.like_count,
                ),
            )
        )

    # Sort by created_at descending
    feed_items.sort(key=lambda x: x.created_at, reverse=True)

    # Apply offset and limit to the combined results
    return feed_items[offset : offset + limit]
