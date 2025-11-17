# Mustory Worker

Async worker responsible for ffmpeg-based HLS encoding and other background jobs
(notifications, retries) referenced in `REQUIREMENTS.md`.  
The worker consumes jobs from the Redis `track_processing` queue created by the API.

## Local run

```bash
cd apps/worker
uv sync  # or pip install -e .
# Ensure Redis + Postgres services are running, then:
python -m mustory_worker.main
```

## Implementation plan

1. Start an `rq` worker bound to the `track_processing` queue.
2. Download source asset via presigned URL, run ffmpeg to produce HLS segments.
3. Upload segments to object storage (R2/S3 compatible), report status back to API.
4. Emit analytics/notification events after success/failure.
