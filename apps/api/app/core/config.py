from functools import lru_cache
import os

from dotenv import load_dotenv
from pydantic import BaseModel, Field

# Load .env file
load_dotenv()


class Settings(BaseModel):
    app_name: str = "Mustory API"
    environment: str = Field(default="local", description="Deployment environment name.")
    database_url: str = Field(
        default="postgresql+psycopg://postgres:postgres@localhost:5432/mustory",
    )
    redis_url: str = Field(default="redis://localhost:6379/0")
    cors_origins: list[str] = Field(default_factory=lambda: ["http://localhost:5173"])
    # Supabase configuration
    supabase_url: str = Field(
        default="",
        description="Supabase project URL",
    )
    supabase_anon_key: str = Field(
        default="",
        description="Supabase anonymous key",
    )
    supabase_service_key: str = Field(
        default="",
        description="Supabase service role key (for admin operations)",
    )


@lru_cache
def get_settings() -> Settings:
    """Return cached settings instance."""
    return Settings(
        environment=os.getenv("ENVIRONMENT", "local"),
        database_url=os.getenv("DATABASE_URL", Settings().database_url),
        redis_url=os.getenv("REDIS_URL", Settings().redis_url),
        supabase_url=os.getenv("SUPABASE_URL", Settings().supabase_url),
        supabase_anon_key=os.getenv("SUPABASE_ANON_KEY", Settings().supabase_anon_key),
        supabase_service_key=os.getenv(
            "SUPABASE_SERVICE_KEY", Settings().supabase_service_key
        ),
    )
