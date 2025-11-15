from __future__ import annotations

from uuid import UUID, uuid4

from sqlalchemy.orm import Session

from app.db import models

DEFAULT_USER_ID = UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")


def create_track(
    session: Session,
    *,
    user_id: UUID = DEFAULT_USER_ID,
    title: str = "Demo Track",
) -> models.Track:
    track = models.Track(
        id=uuid4(),
        title=title,
        artist_name="Tester",
        user_id=user_id,
        artwork_url="https://example.com/art.png",
        hls_url="https://example.com/audio.m3u8",
    )
    session.add(track)
    session.commit()
    return track


def create_story(
    session: Session,
    *,
    track_id: UUID,
    author_user_id: UUID,
    lead: str = "Lead",
    body: str = "Body",
) -> models.Story:
    story = models.Story(
        id=uuid4(),
        track_id=track_id,
        author_user_id=author_user_id,
        lead=lead,
        body=body,
    )
    session.add(story)
    session.commit()
    return story


def create_comment(
    session: Session,
    *,
    target_id: UUID,
    target_type: models.CommentTargetType,
    body: str,
    author_display_name: str = "Listener",
) -> models.Comment:
    comment = models.Comment(
        id=uuid4(),
        author_user_id=DEFAULT_USER_ID,
        author_display_name=author_display_name,
        body=body,
        target_type=target_type.value,
        target_id=target_id,
    )
    session.add(comment)
    session.commit()
    return comment
