# Mustory Monorepo

Operational scaffold for the Flutter + FastAPI + Worker stack described in `AGENTS.md` and
`REQUIREMENTS.md v0.6`.

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

## Local development

| Target | Command |
|--------|---------|
| Flutter | `cd apps/mobile && flutter pub get && flutter run` |
| FastAPI | `cd apps/api && uvicorn app.main:app --reload` |
| Worker | `cd apps/worker && python -m mustory_worker.main` |
| Infra | `docker compose -f infra/docker-compose.yml up --build` |

## Next steps

1. Connect FastAPI to a real Postgres schema + Supabase auth providers.
2. Replace stub data in Flutter with Dio-powered repositories that call the real API.
3. Implement ffmpeg-based HLS pipelines inside the worker and integrate with storage (R2).
4. Add CI workflows (lint/test/build) for each app per AGENTS.md section 9.
