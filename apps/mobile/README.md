# mustory mobile

Flutter-based client focused on the core experience defined in `REQUIREMENTS.md v0.6`.

## Architecture

- `lib/app`: global router, theming, dependency wiring (`ProviderScope`, `GoRouter`).
- `lib/core`: cross-cutting utilities (network/Dio client, analytics, audio session glue, shared models).
- `lib/features`: feature-first folders (e.g., `track_detail`) each split into `data` (API clients), `application`
  (controllers/providers), and `presentation`.

`hooks_riverpod` drives the state graph with async-aware controllers exposed as `AsyncValue`s.

## Getting started

```bash
cd apps/mobile
flutter pub get
flutter run
```

## Next steps

1. Flesh out repositories to call the FastAPI backend once schemas stabilize.
2. Add widget tests for the tabbed track detail flow (`test/features/track_detail/...`).
3. Wire analytics events (`story_open`, `track_comment_posted`) inside the controllers.
