from __future__ import annotations

from datetime import datetime
from enum import Enum
import uuid

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    Enum as SqlEnum,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .base import Base


class User(Base):
    __tablename__ = "users"
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    display_name: Mapped[str] = mapped_column(String(255))
    password_hash: Mapped[str] = mapped_column(String(255))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )


class CommentTargetType(str, Enum):
    TRACK = "track"
    STORY = "story"


class Track(Base):
    __tablename__ = "tracks"
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    title: Mapped[str] = mapped_column(String(255))
    artist_name: Mapped[str] = mapped_column(String(255))
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    artwork_url: Mapped[str] = mapped_column(String(2048))
    hls_url: Mapped[str] = mapped_column(String(2048))
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )

    story: Mapped["Story"] = relationship(back_populates="track", uselist=False)


class Story(Base):
    __tablename__ = "stories"
    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    track_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("tracks.id", ondelete="CASCADE"),
        unique=True,
    )
    author_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    lead: Mapped[str] = mapped_column(String(280))
    body: Mapped[str] = mapped_column(Text)
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )

    track: Mapped[Track] = relationship(back_populates="story")


class Comment(Base):
    __tablename__ = "comments"
    __table_args__ = (
        UniqueConstraint("id"),
        CheckConstraint(
            "(target_type = 'track' AND target_id IS NOT NULL) "
            "OR (target_type = 'story' AND target_id IS NOT NULL)",
            name="comments_target_check",
        ),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    author_user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    author_display_name: Mapped[str] = mapped_column(String(255))
    body: Mapped[str] = mapped_column(Text)
    target_type: Mapped[CommentTargetType] = mapped_column(
        SqlEnum(CommentTargetType), default=CommentTargetType.TRACK
    )
    target_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True))
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
