"""Test script for R2 upload functionality."""

import sys
from pathlib import Path

# Add app to path
sys.path.insert(0, str(Path(__file__).parent))

from app.core.storage import get_storage_client
from app.core.config import get_settings


def test_r2_connection():
    """Test R2 connection and presigned URL generation."""
    print("=" * 60)
    print("Testing R2 Connection")
    print("=" * 60)

    settings = get_settings()

    # Display settings (redacted)
    print(f"\n[OK] Storage Endpoint: {settings.storage_endpoint}")
    print(f"[OK] Storage Bucket: {settings.storage_bucket}")
    print(f"[OK] Storage Region: {settings.storage_region}")
    print(f"[OK] Access Key: {settings.storage_access_key[:10]}..." if settings.storage_access_key else "[X] Not set")
    print(f"[OK] Public URL: {settings.storage_public_url}")

    if not settings.storage_access_key or not settings.storage_secret_key:
        print("\n[ERROR] Storage credentials not configured!")
        print("Please set STORAGE_ACCESS_KEY and STORAGE_SECRET_KEY in .env")
        return False

    try:
        storage = get_storage_client()
        print("\n[OK] Storage client initialized successfully")

        # Test presigned URL generation for audio upload
        print("\n" + "=" * 60)
        print("Testing Presigned URL Generation")
        print("=" * 60)

        audio_presigned = storage.generate_presigned_upload_url(
            object_key="test/sample-track.mp3",
            content_type="audio/mpeg",
            expires_in=3600,
        )

        print("\n[OK] Audio upload presigned URL generated successfully!")
        print(f"  URL: {audio_presigned['url'][:60]}...")
        print(f"  Fields: {list(audio_presigned['fields'].keys())}")

        # Test presigned URL for artwork
        artwork_presigned = storage.generate_presigned_upload_url(
            object_key="test/sample-artwork.jpg",
            content_type="image/jpeg",
            expires_in=3600,
        )

        print("\n[OK] Artwork upload presigned URL generated successfully!")
        print(f"  URL: {artwork_presigned['url'][:60]}...")

        # Test public URL generation
        public_url = storage.get_public_url("tracks/12345/original.mp3")
        print(f"\n[OK] Public URL: {public_url}")

        print("\n" + "=" * 60)
        print("[SUCCESS] All R2 tests passed!")
        print("=" * 60)
        print("\nYou can now test the upload API endpoints:")
        print("  POST http://localhost:8000/tracks/upload/init")
        print("\nExample request:")
        print("""
curl -X POST http://localhost:8000/tracks/upload/init \\
  -H "Content-Type: application/json" \\
  -H "Authorization: Bearer <your_token>" \\
  -d '{
    "title": "My Test Track",
    "artist_name": "Test Artist",
    "file_extension": "mp3",
    "file_size": 5242880,
    "artwork_extension": "jpg"
  }'
        """)

        return True

    except Exception as e:
        print(f"\n[ERROR] {e}")
        print("\nPlease check your R2 configuration:")
        print("1. Verify STORAGE_ENDPOINT is correct")
        print("2. Verify API token has Object Read & Write permissions")
        print("3. Verify bucket name exists and is accessible")
        return False


if __name__ == "__main__":
    success = test_r2_connection()
    sys.exit(0 if success else 1)
