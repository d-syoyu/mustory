from functools import lru_cache
import os

from pydantic import BaseModel, Field


class Settings(BaseModel):
    app_name: str = "Mustory API"
    environment: str = Field(default="local", description="Deployment environment name.")
    database_url: str = Field(
        default="postgresql+psycopg://postgres:postgres@localhost:5432/mustory",
    )
    redis_url: str = Field(default="redis://localhost:6379/0")
    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost:5173"])


@lru_cache
def get_settings() -> Settings:
    """Return cached settings instance."""
    return Settings(
        environment=os.getenv("ENVIRONMENT", "local"),
        database_url=os.getenv("DATABASE_URL", Settings().database_url),
        redis_url=os.getenv("REDIS_URL", Settings().redis_url),
    )
