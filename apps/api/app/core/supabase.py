"""Supabase client configuration."""

from functools import lru_cache

from supabase import Client, create_client

from .config import get_settings


@lru_cache
def get_supabase_client() -> Client:
    """Get cached Supabase client instance."""
    settings = get_settings()
    if not settings.supabase_url or not settings.supabase_anon_key:
        raise ValueError(
            "Supabase credentials not configured. "
            "Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables."
        )
    return create_client(settings.supabase_url, settings.supabase_anon_key)


@lru_cache
def get_supabase_admin_client() -> Client:
    """Get cached Supabase admin client instance (with service role key)."""
    settings = get_settings()
    if not settings.supabase_url or not settings.supabase_service_key:
        raise ValueError(
            "Supabase admin credentials not configured. "
            "Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables."
        )
    return create_client(settings.supabase_url, settings.supabase_service_key)
