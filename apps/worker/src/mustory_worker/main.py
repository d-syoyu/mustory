import asyncio
import logging
from dataclasses import dataclass

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@dataclass(slots=True)
class TranscodeJob:
    track_id: str
    source_url: str
    output_prefix: str


async def process_job(job: TranscodeJob) -> None:
    logger.info("Processing job for track %s", job.track_id)
    await asyncio.sleep(0.5)
    logger.info("Finished stub processing for track %s", job.track_id)


async def worker_loop() -> None:
    logger.info("Worker booted. Waiting for jobs...")
    demo_job = TranscodeJob(
        track_id="demo-track",
        source_url="https://example.com/demo.wav",
        output_prefix="tracks/demo-track",
    )
    await process_job(demo_job)


def main() -> None:
    asyncio.run(worker_loop())


if __name__ == "__main__":
    main()
