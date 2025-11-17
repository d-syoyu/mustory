from uuid import UUID

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models


class _FakeStorageClient:
    def __init__(self) -> None:
        self.generated_keys: list[str] = []

    def generate_presigned_upload_url(
        self,
        object_key: str,
        content_type: str = "audio/mpeg",
        expires_in: int = 3600,
    ) -> str:
        self.generated_keys.append(object_key)
        return f"https://uploads.example.com/{object_key}?expires={expires_in}"

    def get_public_url(self, object_key: str) -> str:
        return f"https://cdn.example.com/{object_key}"


def test_upload_init_creates_track_and_presigned_urls(
    client: TestClient,
    db_session: Session,
    monkeypatch,
) -> None:
    storage = _FakeStorageClient()
    monkeypatch.setattr(
        "app.api.routes.tracks.get_storage_client",
        lambda: storage,
    )

    payload = {
        "title": "Test Song",
        "artist_name": "Tester",
        "file_extension": "mp3",
        "file_size": 1024,
        "artwork_extension": "png",
        "tags": ["#ピアノ", " chill "],
    }

    response = client.post("/tracks/upload/init", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "track_id" in data
    assert data["audio_upload_url"].startswith("https://uploads.example.com/")
    assert data["artwork_upload_url"].startswith("https://uploads.example.com/")

    track = db_session.get(models.Track, UUID(data["track_id"]))
    assert track is not None
    assert track.title == payload["title"]
    assert track.processing_status == models.TrackProcessingStatus.PENDING
    assert track.original_audio_url.startswith("https://cdn.example.com/tracks/")
    assert track.artwork_url.endswith(".png")
    assert track.tags == ["#ピアノ", "chill"]


def test_upload_complete_enqueues_job_for_owner(
    client: TestClient,
    db_session: Session,
    monkeypatch,
) -> None:
    track = models.Track(
        title="Pending Track",
        artist_name="Tester",
        user_id=UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
        artwork_url="https://cdn.example.com/artwork.png",
        hls_url="",
        processing_status=models.TrackProcessingStatus.PENDING,
    )
    db_session.add(track)
    db_session.commit()

    enqueued: list[str] = []

    def _fake_enqueue(track_id: str) -> None:
        enqueued.append(track_id)

    monkeypatch.setattr("app.api.routes.tracks.enqueue_track_processing", _fake_enqueue)

    response = client.post(
        "/tracks/upload/complete",
        json={"track_id": str(track.id)},
    )
    assert response.status_code == 200
    assert response.json()["message"].startswith("Track upload completed")
    assert enqueued == [str(track.id)]


def test_upload_status_returns_processing_info(
    client: TestClient,
    db_session: Session,
) -> None:
    track = models.Track(
        title="Processing Track",
        artist_name="Tester",
        user_id=UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
        artwork_url="https://cdn.example.com/artwork.png",
        hls_url="https://cdn.example.com/hls/playlist.m3u8",
        processing_status=models.TrackProcessingStatus.PROCESSING,
        processing_error=None,
    )
    db_session.add(track)
    db_session.commit()

    response = client.get(f"/tracks/upload/status/{track.id}")
    assert response.status_code == 200
    payload = response.json()
    assert payload["track_id"] == str(track.id)
    assert payload["status"] == "processing"
    assert payload["error"] is None
