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
    # Storage configuration (Cloudflare R2 or S3 compatible)
    storage_endpoint: str = Field(
        default="",
        description="S3-compatible storage endpoint URL",
    )
    storage_access_key: str = Field(
        default="",
        description="Storage access key",
    )
    storage_secret_key: str = Field(
        default="",
        description="Storage secret key",
    )
    storage_bucket: str = Field(
        default="mustory-audio",
        description="Storage bucket name",
    )
    storage_region: str = Field(
        default="auto",
        description="Storage region",
    )
    storage_public_url: str = Field(
        default="",
        description="Public URL base for accessing uploaded files",
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
        storage_endpoint=os.getenv("STORAGE_ENDPOINT", Settings().storage_endpoint),
        storage_access_key=os.getenv("STORAGE_ACCESS_KEY", Settings().storage_access_key),
        storage_secret_key=os.getenv("STORAGE_SECRET_KEY", Settings().storage_secret_key),
        storage_bucket=os.getenv("STORAGE_BUCKET", Settings().storage_bucket),
        storage_region=os.getenv("STORAGE_REGION", Settings().storage_region),
        storage_public_url=os.getenv("STORAGE_PUBLIC_URL", Settings().storage_public_url),
    )
