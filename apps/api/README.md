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

## Next steps

1. Add SQLModel/SQLAlchemy models + migrations.
2. Flesh out repository/service implementations that hit Postgres and worker queues.
3. Cover auth + permission rules in pytest (`apps/api/tests`).
