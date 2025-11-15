from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI

from .api.routes import comments, stories, tracks
from .core.config import get_settings


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    # TODO: initialize db pools, redis, ffmpeg worker queues, etc.
    yield
    # Cleanup hooks here.


settings = get_settings()
app = FastAPI(title=settings.app_name, lifespan=lifespan)

app.include_router(tracks.router)
app.include_router(stories.router)
app.include_router(comments.router)


@app.get("/health", tags=["health"])
async def health() -> dict[str, str]:
    return {"status": "ok", "environment": settings.environment}
