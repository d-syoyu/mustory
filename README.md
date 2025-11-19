# Mustory Monorepo

Operational scaffold for the **Flutter + FastAPI + Worker** stack described in
`AGENTS.md` and `REQUIREMENTS.md v0.6`.

**Status**: Flutter MVP = mainline / Backend & Worker = production-ready / No React Native artifacts remain

## Layout

```
apps/
  mobile/      # Flutter client (hooks_riverpod + GoRouter + just_audio/audio_service)
  api/         # FastAPI backend (tracks/stories/comments endpoints)
  worker/      # Async ffmpeg/notification jobs
packages/      # Shared Dart/Python packages (TBD)
infra/         # Dockerfiles + compose stack (Postgres, Redis, API, worker)
analytics/     # Instrumentation notes and configs
```

## Quick Start

### Prerequisites
- Flutter 3.24+ / Dart 3.5+
- Android Studio & Xcode CLTs (for simulators)
- Docker Desktop
- Python 3.11+
- Supabase project（Auth / DB）

### 1. Setup Supabase / Backend Secrets

See [apps/api/SUPABASE_SETUP.md](apps/api/SUPABASE_SETUP.md) for detailed instructions.

1. Supabase プロジェクトを作成し、Anon key / Service key / Project URL を取得
2. `apps/api/.env.example` を `.env` にコピーし、Supabase や R2 等の環境変数を設定
3. Flutter アプリ用に `apps/mobile/.env` を作成（API base URL, Supabase project etc.）

### 2. Start Infra + API

```bash
# Start database and infrastructure
docker compose -f infra/docker-compose.yml up -d

# Run migrations
cd apps/api && alembic upgrade head

# Start API server locally
cd apps/api && uvicorn app.main:app --reload
```

### 3. Run the Flutter App

```bash
cd apps/mobile
flutter pub get
flutter run -d ios   # or android / macos / windows
dart run build_runner build --delete-conflicting-outputs  # when changing json_serializable models
```

- 実機デバッグ時は `flutter run --release` や `flutter build ipa/apk` を適宜実施
- 音声周りは `BACKGROUND_AUDIO_IMPLEMENTATION.md` の手順（Android 前景サービス等）に追随

### 4. Verify Setup

- http://localhost:8000/docs で FastAPI が応答することを確認
- Flutter アプリから Supabase Auth を経由してログイン・コメント投稿ができるか確認

## Local Development Commands

| Target | Command |
|--------|---------|
| Full Stack | `docker compose -f infra/docker-compose.yml up --build` |
| API Only | `cd apps/api && uvicorn app.main:app --reload` |
| Worker | `cd apps/worker && python -m mustory_worker.main` |
| Flutter App (Dev) | `cd apps/mobile && flutter run` |
| Flutter Analyze | `cd apps/mobile && flutter analyze` |
| Flutter Tests | `cd apps/mobile && flutter test --coverage` |
| Flutter Integration Test | `cd apps/mobile && flutter test integration_test` |
| Tests (API) | `cd apps/api && pytest -v` |

## Completed Features

- [x] FastAPI + Worker backend（tracks/stories/comments/likes, Supabase Auth, ffmpeg worker）
- [x] Flutter client with upload flow、track detail tabs、background audio
- [x] Infrastructure scaffold（Docker Compose, Alembic, CI placeholders）

## Current Focus

1. Flesh out analytics events（`play_start`, `story_open` etc.）
2. Expand widget/integration tests for track detail + upload flows
3. Wire automated release scripts for Flutter IPA / AAB builds
