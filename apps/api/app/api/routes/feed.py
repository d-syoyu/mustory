"""
Feed API routes for follow-based content discovery.
"""

from datetime import datetime
from typing import Literal

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel
from sqlalchemy import select

from app.db.models import Follow, Story, Track, User
from app.dependencies.database import DbSession
from app.dependencies.supabase_auth import CurrentUser

router = APIRouter(prefix="/feed", tags=["feed"])


class UserInfo(BaseModel):
    id: str
    username: str
    display_name: str
    avatar_url: str | None = None

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


class FollowFeedResponse(BaseModel):
    items: list[FeedItem]
    next_cursor: str | None = None


@router.get("/following", response_model=FollowFeedResponse)
async def get_following_feed(
    current_user: CurrentUser,
    db: DbSession,
    limit: int = Query(50, le=100),
    cursor: str | None = Query(None),
) -> FollowFeedResponse:
    """
    Get feed of tracks and stories from users the current user follows.
    Returns items sorted by creation time (newest first).
    """
    cursor_dt: datetime | None = None
    if cursor:
        try:
            cursor_dt = datetime.fromisoformat(cursor)
        except ValueError:
            raise HTTPException(
                status_code=400, detail="Invalid cursor format, use ISO 8601 datetime"
            )

    # Get list of followed user IDs
    followed_users_result = db.execute(
        select(Follow.followee_id).where(Follow.follower_id == current_user.id)
    )
    followed_user_ids = [row[0] for row in followed_users_result.all()]

    if not followed_user_ids:
        return FollowFeedResponse(items=[], next_cursor=None)

    # Get tracks from followed users
    track_query = (
        select(Track, User)
        .join(User, Track.user_id == User.id)
        .where(Track.user_id.in_(followed_user_ids))
    )
    if cursor_dt:
        track_query = track_query.where(Track.created_at < cursor_dt)
    tracks_result = db.execute(track_query.order_by(Track.created_at.desc()).limit(limit + 1))
    tracks = tracks_result.all()

    # Get stories from followed users
    story_query = (
        select(Story, User, Track)
        .join(User, Story.author_user_id == User.id)
        .join(Track, Story.track_id == Track.id)
        .where(Story.author_user_id.in_(followed_user_ids))
    )
    if cursor_dt:
        story_query = story_query.where(Story.created_at < cursor_dt)
    stories_result = db.execute(story_query.order_by(Story.created_at.desc()).limit(limit + 1))
    stories = stories_result.all()

    # Combine and sort by created_at
    feed_items: list[FeedItem] = []

    for track, user in tracks:
        feed_items.append(
            FeedItem(
                type="track",
                created_at=track.created_at,
                user=UserInfo(
                    id=str(user.id),
                    username=user.username,
                    display_name=user.display_name,
                    avatar_url=user.avatar_url,
                ),
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
                user=UserInfo(
                    id=str(user.id),
                    username=user.username,
                    display_name=user.display_name,
                    avatar_url=user.avatar_url,
                ),
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

    has_more = len(feed_items) > limit
    items = feed_items[:limit]
    next_cursor = items[-1].created_at.isoformat() if has_more else None

    return FollowFeedResponse(items=items, next_cursor=next_cursor)
