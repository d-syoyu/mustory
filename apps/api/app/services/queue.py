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


def enqueue_track_processing(track_id: str) -> str:
    """Enqueue a track for FFmpeg HLS conversion.

    Args:
        track_id: UUID of the track to process

    Returns:
        Job ID for tracking progress
    """
    from .worker import process_track_to_hls

    job = track_processing_queue.enqueue(
        process_track_to_hls,
        track_id,
        job_timeout="10m",  # 10 minutes timeout
    )
    print(f"Enqueued track {track_id} for processing (job {job.id})")
    return job.id


def get_job_progress(job_id: str) -> int | None:
    """Get progress percentage for a job.

    Args:
        job_id: Redis job ID

    Returns:
        Progress percentage (0-100) or None if not available
    """
    from rq.job import Job

    try:
        job = Job.fetch(job_id, connection=redis_conn)

        # Check job status
        if job.is_finished:
            return 100
        elif job.is_failed:
            return None
        elif job.is_started:
            # For jobs in progress, check if there's custom progress metadata
            meta = job.get_meta()
            if "progress" in meta:
                return int(meta["progress"])
            # Default progress for started jobs
            return 50
        else:
            # Job is queued but not started
            return 0

    except Exception:
        # Job not found or error fetching
        return None
