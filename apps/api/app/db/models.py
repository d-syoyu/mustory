from __future__ import annotations

from datetime import datetime
from enum import Enum
import uuid

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    Enum as SqlEnum,
    Float,
    ForeignKey,
    Integer,
    JSON,
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


class TrackProcessingStatus(str, Enum):
    PENDING = "pending"  # Upload started, waiting for file
    PROCESSING = "processing"  # FFmpeg conversion in progress
    COMPLETED = "completed"  # Ready to play
    FAILED = "failed"  # Processing failed


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
    # Upload and processing fields
    original_audio_url: Mapped[str | None] = mapped_column(String(2048), nullable=True)
    processing_status: Mapped[TrackProcessingStatus] = mapped_column(
        SqlEnum(TrackProcessingStatus), default=TrackProcessingStatus.PENDING
    )
    processing_error: Mapped[str | None] = mapped_column(Text, nullable=True)
    job_id: Mapped[str | None] = mapped_column(String(255), nullable=True)
    duration_seconds: Mapped[int | None] = mapped_column(Integer, nullable=True)
    bpm: Mapped[float | None] = mapped_column(Float, nullable=True)
    loudness_lufs: Mapped[float | None] = mapped_column(Float, nullable=True)
    mood_valence: Mapped[float | None] = mapped_column(Float, nullable=True)
    mood_energy: Mapped[float | None] = mapped_column(Float, nullable=True)
    has_vocals: Mapped[bool | None] = mapped_column(Boolean, nullable=True)
    audio_embedding: Mapped[list[float] | None] = mapped_column(JSON, nullable=True)
    tags: Mapped[list[str]] = mapped_column(JSON, default=list)
    # Metadata
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    view_count: Mapped[int] = mapped_column(Integer, default=0)
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
    parent_comment_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), nullable=True, default=None
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )
    like_count: Mapped[int] = mapped_column(Integer, default=0)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    reply_count: Mapped[int] = mapped_column(Integer, default=0)


class LikeTrack(Base):
    __tablename__ = "like_tracks"
    __table_args__ = (
        UniqueConstraint("user_id", "track_id", name="unique_user_track_like"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    track_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("tracks.id", ondelete="CASCADE"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )


class LikeStory(Base):
    __tablename__ = "like_stories"
    __table_args__ = (
        UniqueConstraint("user_id", "story_id", name="unique_user_story_like"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    story_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("stories.id", ondelete="CASCADE"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )


class LikeComment(Base):
    __tablename__ = "like_comments"
    __table_args__ = (
        UniqueConstraint("user_id", "comment_id", name="unique_user_comment_like"),
    )

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    comment_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("comments.id", ondelete="CASCADE"),
        nullable=False,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )


class Follow(Base):
    __tablename__ = "follows"
    __table_args__ = (
        UniqueConstraint("follower_id", "followee_id", name="unique_follow"),
    )

    follower_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    followee_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        primary_key=True,
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=datetime.utcnow
    )
