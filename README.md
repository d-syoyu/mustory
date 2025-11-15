# Mustory Monorepo

Operational scaffold for the Flutter + FastAPI + Worker stack described in `AGENTS.md` and
`REQUIREMENTS.md v0.6`.

**Status**: ✅ Core infrastructure ready with Supabase Auth integration

## Layout

```
apps/
  mobile/   # Flutter client (hooks_riverpod, go_router, just_audio)
  api/      # FastAPI backend (tracks/stories/comments endpoints)
  worker/   # Async ffmpeg/notification jobs
packages/   # Shared Dart/Python packages (TBD)
infra/      # Dockerfiles + compose stack (Postgres, Redis, API, worker)
analytics/  # Instrumentation notes and configs
```

## Quick Start

### Prerequisites
- Docker Desktop
- Python 3.11+
- Flutter 3.38+
- Supabase account (for authentication)

### 1. Setup Supabase

See [apps/api/SUPABASE_SETUP.md](apps/api/SUPABASE_SETUP.md) for detailed instructions.

Quick steps:
1. Create Supabase project at [supabase.com](https://supabase.com)
2. Copy `.env.example` to `.env` in `apps/api/`
3. Add your Supabase credentials

### 2. Start Services

```bash
# Start database and infrastructure
docker compose -f infra/docker-compose.yml up -d

# Run database migrations
cd apps/api && alembic upgrade head

# Start API server
uvicorn app.main:app --reload
```

### 3. Verify Setup

Visit http://localhost:8000/docs to see API documentation.

Test authentication:
```bash
curl -X POST http://localhost:8000/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123","display_name":"Test User"}'
```

## Local Development Commands

| Target | Command |
|--------|---------|
| Full Stack | `docker compose -f infra/docker-compose.yml up --build` |
| API Only | `cd apps/api && uvicorn app.main:app --reload` |
| Flutter | `cd apps/mobile && flutter pub get && flutter run` |
| Worker | `cd apps/worker && python -m mustory_worker.main` |
| Tests (API) | `cd apps/api && pytest -v` |
| Tests (Flutter) | `cd apps/mobile && flutter test` |

## Completed Features ✅

- [x] Database schema (Track, Story, Comment models)
- [x] Like tables (LikeTrack, LikeStory, LikeComment)
- [x] Alembic migrations
- [x] API endpoints for tracks, stories, comments
- [x] Like/unlike functionality for tracks, stories, and comments
- [x] Supabase Auth integration
- [x] Docker containerization (API, Worker, PostgreSQL, Redis)
- [x] Comprehensive test suite (20 tests passing)
- [x] Flutter mobile app scaffold
- [x] Worker skeleton for FFmpeg jobs

## Next Steps

### Phase 1: Complete MVP Core Features
1. ~~Setup Supabase authentication~~ ✅
2. ~~Implement track listing endpoint (`GET /tracks`)~~ ✅
3. ~~Add like/unlike functionality~~ ✅
4. Integrate Supabase auth with Flutter app

### Phase 2: Audio & Storage
5. Implement FFmpeg HLS conversion in worker
6. Integrate Cloudflare R2 for audio storage
7. Add presigned URL generation for uploads

### Phase 3: Polish & Deploy
8. Add CI/CD workflows (GitHub Actions)
9. Deploy to Railway/Render
10. Configure production Supabase project

See [REQUIREMENTS.md](REQUIREMENTS.md) for full feature specification.
