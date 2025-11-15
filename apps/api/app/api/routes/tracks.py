from __future__ import annotations

from typing import Iterable
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from ...db import models
from ...dependencies.auth import CurrentUser
from ...dependencies.database import DbSession
from ...schemas.comments import CommentCreateSchema, CommentSchema
from ...schemas.story import StorySchema
from ...schemas.tracks import TrackDetailResponse, TrackSchema

router = APIRouter(prefix="/tracks", tags=["tracks"])


@router.get("/{track_id}", response_model=TrackDetailResponse)
def get_track_detail(track_id: UUID, db: DbSession) -> TrackDetailResponse:
    track = db.get(models.Track, track_id)
    if not track:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Track not found.")

    story_schema = _map_story(track.story) if track.story else None
    track_comments = _map_comments(
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
    story_comments: list[CommentSchema] = []
    if track.story:
        story_comments = _map_comments(
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

    return TrackDetailResponse(
        track=_map_track(track, story_schema),
        track_comments=track_comments,
        story_comments=story_comments,
    )


@router.get("/{track_id}/comments", response_model=list[CommentSchema])
def list_track_comments(track_id: UUID, db: DbSession) -> list[CommentSchema]:
    return _map_comments(
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

    comment = models.Comment(
        author_user_id=current_user.id,
        author_display_name=current_user.display_name,
        body=payload.body.strip(),
        target_type=models.CommentTargetType.TRACK,
        target_id=track_id,
    )
    db.add(comment)
    db.commit()
    db.refresh(comment)
    return _map_comment(comment)


def _map_track(track: models.Track, story_schema: StorySchema | None) -> TrackSchema:
    return TrackSchema(
        id=track.id,
        title=track.title,
        artist_name=track.artist_name,
        user_id=track.user_id,
        artwork_url=track.artwork_url,
        hls_url=track.hls_url,
        like_count=track.like_count,
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


def _map_comments(rows: Iterable[models.Comment]) -> list[CommentSchema]:
    return [_map_comment(comment) for comment in rows]


def _map_comment(comment: models.Comment) -> CommentSchema:
    return CommentSchema(
        id=comment.id,
        author_user_id=comment.author_user_id,
        author_display_name=comment.author_display_name,
        body=comment.body,
        created_at=comment.created_at,
        target_type=comment.target_type.value,
        target_id=comment.target_id,
        like_count=comment.like_count,
    )
