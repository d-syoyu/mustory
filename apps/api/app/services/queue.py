"""Redis Queue configuration and helpers for background jobs."""

from __future__ import annotations

import redis
from rq import Queue

from ..core.config import get_settings

# Create Redis connection
settings = get_settings()
redis_conn = redis.from_url(settings.redis_url)

# Create queue for track processing
track_processing_queue = Queue("track_processing", connection=redis_conn)


def enqueue_track_processing(track_id: str) -> None:
    """Enqueue a track for FFmpeg HLS conversion.

    Args:
        track_id: UUID of the track to process
    """
    from .worker import process_track_to_hls

    job = track_processing_queue.enqueue(
        process_track_to_hls,
        track_id,
        job_timeout="10m",  # 10 minutes timeout
    )
    print(f"Enqueued track {track_id} for processing (job {job.id})")
