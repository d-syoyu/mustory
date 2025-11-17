from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from datetime import datetime
from typing import Sequence
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session, selectinload

from app.db import models


@dataclass(slots=True)
class TrackEngagementStats:
    """Aggregated engagement signals for a track."""

    track_comment_count: int = 0
    story_comment_count: int = 0

    @property
    def total_comments(self) -> int:
        return self.track_comment_count + self.story_comment_count


@dataclass(slots=True)
class UserPreferenceProfile:
    """User-level interaction summary for personalization."""

    user_id: UUID
    preferred_creator_scores: dict[UUID, float]
    interacted_track_ids: set[UUID]
    story_affinity: float

    def top_creator_ids(self, limit: int = 5) -> list[UUID]:
        return [
            creator_id
            for creator_id, _ in sorted(
                self.preferred_creator_scores.items(),
                key=lambda item: item[1],
                reverse=True,
            )[:limit]
        ]


class RecommendationService:
    """
    Hybrid recommendation engine that combines collaborative, content, and recency signals.

    Design goals:
    - Always return high-quality trending tracks even for signed-out listeners.
    - Blend in personal affinity when we know the listener's preferred creators/stories.
    - Encourage story consumption by boosting tracks with active stories when the user shows interest.
    - Avoid repeating the same creator too many times in a short list.
    """

    def __init__(self, db: Session):
        self.db = db

    def recommend_tracks(self, *, user_id: UUID | None, limit: int = 20) -> list[models.Track]:
        """Return ranked track candidates honoring hybrid scoring."""
        profile = self._build_user_profile(user_id) if user_id else None
        candidate_tracks = self._load_candidate_tracks(profile, limit)
        if not candidate_tracks:
            return []

        stats_map = self._load_track_engagement_stats([track.id for track in candidate_tracks])
        scored_candidates: list[tuple[models.Track, float]] = [
            (track, self._score_track(track, stats_map.get(track.id), profile))
            for track in candidate_tracks
        ]
        scored_candidates.sort(key=lambda item: item[1], reverse=True)
        return self._apply_diversity(scored_candidates, limit, profile)

    def _build_user_profile(self, user_id: UUID) -> UserPreferenceProfile | None:
        """Aggregate interactions (likes/comments) to build a lightweight preference profile."""
        liked_tracks = self.db.execute(
            select(models.Track.id, models.Track.user_id)
            .join(models.LikeTrack, models.LikeTrack.track_id == models.Track.id)
            .where(models.LikeTrack.user_id == user_id)
        ).all()

        track_comment_rows = self.db.execute(
            select(models.Track.id, models.Track.user_id)
            .join(models.Comment, models.Comment.target_id == models.Track.id)
            .where(
                models.Comment.author_user_id == user_id,
                models.Comment.target_type == models.CommentTargetType.TRACK,
                models.Comment.is_deleted.is_(False),
            )
        ).all()

        story_comment_rows = self.db.execute(
            select(models.Track.id, models.Track.user_id)
            .join(models.Story, models.Story.track_id == models.Track.id)
            .join(models.Comment, models.Comment.target_id == models.Story.id)
            .where(
                models.Comment.author_user_id == user_id,
                models.Comment.target_type == models.CommentTargetType.STORY,
                models.Comment.is_deleted.is_(False),
            )
        ).all()

        story_like_rows = self.db.execute(
            select(models.Track.id, models.Track.user_id)
            .join(models.Story, models.Story.track_id == models.Track.id)
            .join(models.LikeStory, models.LikeStory.story_id == models.Story.id)
            .where(models.LikeStory.user_id == user_id)
        ).all()

        if not (liked_tracks or track_comment_rows or story_comment_rows or story_like_rows):
            return None

        creator_scores: dict[UUID, float] = defaultdict(float)
        interacted_track_ids: set[UUID] = set()

        for row in liked_tracks:
            creator_scores[row.user_id] += 3.0
            interacted_track_ids.add(row.id)

        for row in track_comment_rows:
            creator_scores[row.user_id] += 1.5
            interacted_track_ids.add(row.id)

        for row in story_comment_rows:
            creator_scores[row.user_id] += 1.2
            interacted_track_ids.add(row.id)

        for row in story_like_rows:
            creator_scores[row.user_id] += 2.2
            interacted_track_ids.add(row.id)

        track_interactions = len(liked_tracks) + len(track_comment_rows)
        story_interactions = len(story_comment_rows) + len(story_like_rows)
        total_interactions = track_interactions + story_interactions
        story_affinity = (
            story_interactions / total_interactions if total_interactions > 0 else 0.35
        )

        # Normalize to 0-1 range to keep final score bounded.
        max_score = max(creator_scores.values())
        normalized_scores = (
            {creator_id: score / max_score for creator_id, score in creator_scores.items()}
            if max_score
            else dict(creator_scores)
        )

        return UserPreferenceProfile(
            user_id=user_id,
            preferred_creator_scores=normalized_scores,
            interacted_track_ids=interacted_track_ids,
            story_affinity=story_affinity,
        )

    def _load_candidate_tracks(
        self,
        profile: UserPreferenceProfile | None,
        limit: int,
    ) -> list[models.Track]:
        """Fetch a blended pool of candidate tracks before final ranking."""
        candidate_budget = max(limit * 4, 40)
        candidate_map: dict[UUID, models.Track] = {}

        queries = [
            select(models.Track)
            .options(selectinload(models.Track.story))
            .order_by(models.Track.created_at.desc())
            .limit(candidate_budget),
            select(models.Track)
            .options(selectinload(models.Track.story))
            .order_by(models.Track.like_count.desc(), models.Track.view_count.desc())
            .limit(candidate_budget),
            select(models.Track)
            .options(selectinload(models.Track.story))
            .join(models.Story)
            .order_by(models.Story.like_count.desc(), models.Track.created_at.desc())
            .limit(candidate_budget),
        ]

        if profile:
            creator_ids = profile.top_creator_ids()
            if creator_ids:
                queries.append(
                    select(models.Track)
                    .options(selectinload(models.Track.story))
                    .where(models.Track.user_id.in_(creator_ids))
                    .order_by(models.Track.created_at.desc())
                    .limit(candidate_budget),
                )

        for query in queries:
            for track in self.db.scalars(query):
                if track.id not in candidate_map:
                    candidate_map[track.id] = track

        return list(candidate_map.values())

    def _load_track_engagement_stats(
        self,
        track_ids: Sequence[UUID],
    ) -> dict[UUID, TrackEngagementStats]:
        """Batch-load engagement aggregates for scoring."""
        if not track_ids:
            return {}

        track_comment_rows = self.db.execute(
            select(
                models.Comment.target_id.label("track_id"),
                func.count(models.Comment.id).label("track_comment_count"),
            )
            .where(
                models.Comment.target_type == models.CommentTargetType.TRACK,
                models.Comment.target_id.in_(track_ids),
                models.Comment.is_deleted.is_(False),
            )
            .group_by(models.Comment.target_id)
        ).all()

        story_comment_rows = self.db.execute(
            select(
                models.Story.track_id.label("track_id"),
                func.count(models.Comment.id).label("story_comment_count"),
            )
            .join(models.Comment, models.Comment.target_id == models.Story.id)
            .where(
                models.Comment.target_type == models.CommentTargetType.STORY,
                models.Story.track_id.in_(track_ids),
                models.Comment.is_deleted.is_(False),
            )
            .group_by(models.Story.track_id)
        ).all()

        stats: dict[UUID, TrackEngagementStats] = defaultdict(TrackEngagementStats)
        for row in track_comment_rows:
            stats[row.track_id].track_comment_count = row.track_comment_count  # type: ignore[attr-defined]
        for row in story_comment_rows:
            stats[row.track_id].story_comment_count = row.story_comment_count  # type: ignore[attr-defined]
        return stats

    def _score_track(
        self,
        track: models.Track,
        stats: TrackEngagementStats | None,
        profile: UserPreferenceProfile | None,
    ) -> float:
        """Compute the final score for a track."""
        stats = stats or TrackEngagementStats()
        now = datetime.utcnow()
        created_at = track.created_at or now
        age_hours = max((now - created_at).total_seconds() / 3600, 0.0)
        recency_component = 1 / (1 + age_hours / 72)
        fresh_boost = 0.35 if age_hours < 6 else 0.0

        story_like_count = track.story.like_count if track.story else 0
        story_bonus = 1.0 if track.story else 0.0
        story_bonus += 0.05 * stats.story_comment_count

        base_popularity = (
            (track.like_count or 0) * 1.3
            + stats.track_comment_count * 0.9
            + stats.story_comment_count * 0.8
            + (track.view_count or 0) * 0.05
            + story_like_count * 0.6
        )

        score = base_popularity * recency_component + fresh_boost + story_bonus

        if profile:
            creator_weight = profile.preferred_creator_scores.get(track.user_id)
            if creator_weight:
                score += 5.0 * creator_weight
            if track.story:
                score *= 1 + 0.2 * profile.story_affinity
            if track.id in profile.interacted_track_ids:
                score *= 0.35

        return score

    def _apply_diversity(
        self,
        scored_tracks: Sequence[tuple[models.Track, float]],
        limit: int,
        profile: UserPreferenceProfile | None,
    ) -> list[models.Track]:
        """Limit repeated creators while guaranteeing some personalized picks."""
        per_creator_cap = 2 if limit >= 5 else 1
        seen_per_creator: dict[UUID, int] = defaultdict(int)
        ranked: list[models.Track] = []
        added_track_ids: set[UUID] = set()

        def try_add(track: models.Track) -> bool:
            if track.id in added_track_ids:
                return False
            if seen_per_creator[track.user_id] >= per_creator_cap:
                return False
            ranked.append(track)
            added_track_ids.add(track.id)
            seen_per_creator[track.user_id] += 1
            return True

        if profile and profile.preferred_creator_scores:
            personalized_target = max(1, limit // 4 + 1)
            personalized_added = 0
            for track, _ in scored_tracks:
                if track.user_id not in profile.preferred_creator_scores:
                    continue
                if try_add(track):
                    personalized_added += 1
                if personalized_added >= personalized_target or len(ranked) >= limit:
                    break

        for track, _ in scored_tracks:
            if len(ranked) >= limit:
                break
            try_add(track)

        if len(ranked) < limit:
            for track, _ in scored_tracks:
                if track.id in added_track_ids:
                    continue
                ranked.append(track)
                added_track_ids.add(track.id)
                if len(ranked) >= limit:
                    break
        return ranked


__all__ = ["RecommendationService", "TrackEngagementStats", "UserPreferenceProfile"]
