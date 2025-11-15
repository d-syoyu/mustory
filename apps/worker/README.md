# Mustory Worker

Async worker responsible for ffmpeg-based HLS encoding and other background jobs
(notifications, retries) referenced in `REQUIREMENTS.md`.

## Local run

```bash
cd apps/worker
uv sync
python -m mustory_worker.main
```

## Implementation plan

1. Watch Redis streams / Postgres NOTIFY for new track jobs.
2. Download source asset via presigned URL, run ffmpeg to produce HLS segments.
3. Upload segments to object storage (R2/S3 compatible), report status back to API.
4. Emit analytics/notification events after success/failure.
