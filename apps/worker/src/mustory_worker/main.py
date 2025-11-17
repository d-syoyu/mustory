"""RQ worker entrypoint for FFmpeg/HLS jobs."""

from __future__ import annotations

import logging
import os
import sys
from pathlib import Path

import redis
from rq import Connection, Worker


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s - %(message)s",
)
logger = logging.getLogger("mustory.worker")

# Ensure the FastAPI app package (apps/api/app) is importable so that
# rq jobs can resolve `app.services.worker.process_track_to_hls`.
PROJECT_ROOT = Path(__file__).resolve().parents[4]
API_PATH = PROJECT_ROOT / "apps" / "api"
if str(API_PATH) not in sys.path:
    sys.path.insert(0, str(API_PATH))

# Now that the path is injected we can import the shared settings helper.
from app.core.config import get_settings  # noqa: E402

QUEUE_NAME = "track_processing"


def _create_redis_connection() -> redis.Redis:
    settings = get_settings()
    redis_url = settings.redis_url
    logger.info("Connecting to Redis at %s", redis_url)
    return redis.from_url(redis_url)


def main() -> None:
    """Run an rq worker that consumes track processing jobs."""
    logging.getLogger("rq.worker").setLevel(logging.INFO)
    connection = _create_redis_connection()
    with Connection(connection):
        worker = Worker([QUEUE_NAME])
        logger.info("Worker started. Listening on queue '%s'.", QUEUE_NAME)
        worker.work(
            with_scheduler=True,
            logging_level=logging.INFO,
        )


if __name__ == "__main__":
    main()
