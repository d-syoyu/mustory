from __future__ import annotations

from typing import Iterable
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query, status
from sqlalchemy import select

from ...db import models
from ...dependencies.supabase_auth import CurrentUser, OptionalCurrentUser
from ...dependencies.database import DbSession
from ...schemas.comments import CommentCreateSchema, CommentSchema
from ...schemas.story import StoryCreateSchema, StorySchema, StoryUpdateSchema

router = APIRouter(prefix="/stories", tags=["stories"])


@router.get("/liked", response_model=list[StorySchema])
def list_liked_stories(
    db: DbSession,
    current_user: CurrentUser,
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
) -> list[StorySchema]:
    """
    List stories liked by the current user.

    - **limit**: Maximum number of stories to return (1-100, default 20)
    - **offset**: Number of stories to skip (default 0)
    - Returns liked stories ordered by most recently liked first
    """
    # Get liked story IDs for the current user
    liked_story_ids = db.scalars(
        select(models.LikeStory.story_id)
        .where(models.LikeStory.user_id == current_user.id)
        .order_by(models.LikeStory.created_at.desc())
        .limit(limit)
        .offset(offset)
    ).all()

    if not liked_story_ids:
        return []

    # Fetch stories
    stories = db.scalars(
        select(models.Story)
        .where(models.Story.id.in_(liked_story_ids))
    ).all()

    # Preserve the order from liked_story_ids
    story_dict = {story.id: story for story in stories}
    ordered_stories = [story_dict[story_id] for story_id in liked_story_ids if story_id in story_dict]

    # All stories in this endpoint are liked by the current user
    return [
        StorySchema(
            id=story.id,
            track_id=story.track_id,
            author_user_id=story.author_user_id,
            lead=story.lead,
            body=story.body,
            like_count=story.like_count,
            is_liked=True,
            created_at=story.created_at,
        )
        for story in ordered_stories
    ]


@router.get("/{story_id}", response_model=StorySchema)
def get_story(story_id: UUID, db: DbSession) -> StorySchema:
    story = db.get(models.Story, story_id)
    if not story:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found.")
    return _map_story(story)


@router.post(
    "/{story_id}/comments",
    response_model=CommentSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_story_comment(
    story_id: UUID,
    payload: CommentCreateSchema,
    db: DbSession,
    current_user: CurrentUser,
) -> CommentSchema:
    story = db.get(models.Story, story_id)
    if not story:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found.")
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
        # Verify parent comment is for the same story
        if parent_comment.target_type != models.CommentTargetType.STORY or parent_comment.target_id != story_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Parent comment does not belong to this story.",
            )

    comment = models.Comment(
        author_user_id=current_user.id,
        author_display_name=current_user.display_name,
        body=payload.body.strip(),
        target_type=models.CommentTargetType.STORY,
        target_id=story_id,
        parent_comment_id=payload.parent_comment_id,
    )
    db.add(comment)

    # Increment parent comment's reply_count if this is a reply
    if payload.parent_comment_id:
        parent_comment.reply_count += 1

    db.commit()
    db.refresh(comment)
    return _map_comment(comment, current_user.id, db)


@router.put("/{story_id}", response_model=StorySchema)
def update_story(
    story_id: UUID,
    payload: StoryUpdateSchema,
    db: DbSession,
    current_user: CurrentUser,
) -> StorySchema:
    story = db.get(models.Story, story_id)
    if not story:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found.")
    if story.author_user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden.")

    if payload.lead:
        story.lead = payload.lead
    if payload.body:
        story.body = payload.body

    db.add(story)
    db.commit()
    db.refresh(story)
    return _map_story(story)


@router.post(
    "/track/{track_id}",
    response_model=StorySchema,
    status_code=status.HTTP_201_CREATED,
)
def create_story(
    track_id: UUID,
    payload: StoryCreateSchema,
    db: DbSession,
    current_user: CurrentUser,
) -> StorySchema:
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")
    if track.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden.")
    if track.story:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Story already exists for track.",
        )

    story = models.Story(
        track_id=track_id,
        author_user_id=current_user.id,
        lead=payload.lead,
        body=payload.body,
    )
    db.add(story)
    db.commit()
    db.refresh(story)
    return _map_story(story)


@router.get("/{story_id}/comments", response_model=list[CommentSchema])
def list_story_comments(
    story_id: UUID,
    db: DbSession,
    current_user: OptionalCurrentUser,
) -> list[CommentSchema]:
    comments_rows = list(
        db.scalars(
            select(models.Comment)
            .where(
                models.Comment.target_type == models.CommentTargetType.STORY,
                models.Comment.target_id == story_id,
                models.Comment.is_deleted.is_(False),
            )
            .order_by(models.Comment.created_at.desc())
        )
    )
    return _map_comments(comments_rows, current_user, db)


@router.post("/{story_id}/like", status_code=status.HTTP_201_CREATED)
def like_story(
    story_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Like a story."""
    story = db.get(models.Story, story_id)
    if not story:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found.")

    # Check if already liked
    existing_like = db.scalar(
        select(models.LikeStory).where(
            models.LikeStory.user_id == current_user.id,
            models.LikeStory.story_id == story_id,
        )
    )
    if existing_like:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Story already liked.",
        )

    # Create like
    like = models.LikeStory(user_id=current_user.id, story_id=story_id)
    db.add(like)

    # Increment like_count
    story.like_count += 1

    db.commit()
    return {"message": "Story liked successfully."}


@router.delete("/{story_id}/like", status_code=status.HTTP_200_OK)
def unlike_story(
    story_id: UUID,
    db: DbSession,
    current_user: CurrentUser,
) -> dict:
    """Unlike a story."""
    story = db.get(models.Story, story_id)
    if not story:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Story not found.")

    # Find existing like
    like = db.scalar(
        select(models.LikeStory).where(
            models.LikeStory.user_id == current_user.id,
            models.LikeStory.story_id == story_id,
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
    if story.like_count > 0:
        story.like_count -= 1

    db.commit()
    return {"message": "Story unliked successfully."}


def _map_story(story: models.Story) -> StorySchema:
    return StorySchema(
        id=story.id,
        track_id=story.track_id,
        author_user_id=story.author_user_id,
        lead=story.lead,
        body=story.body,
        like_count=story.like_count,
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
