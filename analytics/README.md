# Analytics

Guidelines for instrumentation per AGENTS.md section 12.

- Track player events: `play_start`, `story_open`, `track_comment_posted`, `story_comment_posted`.
- Delivery targets: PostHog (product analytics) + Sentry (error/perf).

## Suggested folder layout

```
analytics/
  posthog/
    events.md
  sentry/
    config.yml
```

Populate these subfolders as instrumentation is implemented.
