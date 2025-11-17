# Mustory API

FastAPI application exposing track, story, comment, and notification endpoints as defined in
`REQUIREMENTS.md v0.6`.

## Local setup

```bash
cd apps/api
uv sync  # or pip install -e .[dev]
uvicorn app.main:app --reload
```

## Structure

- `app/core`: configuration, db sessions, auth helpers.
- `app/api/routes`: routers grouped by resource (tracks, stories, comments).
- `app/schemas`: Pydantic v2 models for request/response payloads.
- `app/services`: business logic orchestrating repositories/services.
- `app/dependencies`: composable FastAPI dependencies (current user, pagination, etc.).

## Recommendation API

- `GET /tracks/recommendations?limit=20`  
  Returns a ranked list of tracks using a hybrid algorithm implemented in `app/services/recommendations.py`.
  Signals considered:
  - Global popularity: likes, comments, story likes, and view counts.
  - Recency decay and lightweight "fresh" boosts.
  - Story depth: tracks with active stories and high discussion density get extra weight.
  - Personalization: for signed-in listeners the service boosts creators they have liked/commented on and reserves the first slot(s) for those creators.
  - Diversity: caps repeats per creator while backfilling with trending tracks if the pool is small.

## Audio Feature Extraction (P0)

- When the worker finishes HLS conversion it now runs `app/services/audio_analysis.py` against the uploaded source.
- Persisted descriptors:
  - `audio_embedding` (128-dim log-mel embedding stored as JSON)
  - `duration_seconds`, `bpm`, `loudness_lufs`
  - `mood_valence`, `mood_energy`, `has_vocals`
  - `tags` (user supplied at upload/init)
- These values are exposed on `TrackSchema` so mobile/web clients can filter/sort immediately, and they form the base features for upcoming recommendation and analytics work.

## Next steps

1. Add SQLModel/SQLAlchemy models + migrations.
2. Flesh out repository/service implementations that hit Postgres and worker queues.
3. Cover auth + permission rules in pytest (`apps/api/tests`).
