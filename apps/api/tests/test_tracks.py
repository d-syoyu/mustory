from datetime import datetime, timedelta
from uuid import UUID, uuid4

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
from app.dependencies.supabase_auth import get_current_user_id_optional
from app.main import app
from tests import factories


def test_get_track_detail_returns_story_and_comments(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    story = factories.create_story(
        db_session,
        track_id=track.id,
        author_user_id=track.user_id,
        lead="Lead",
        body="Body",
    )
    factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Track comment",
    )
    factories.create_comment(
        db_session,
        target_id=story.id,
        target_type=models.CommentTargetType.STORY,
        body="Story comment",
    )

    response = client.get(f"/tracks/{track.id}")
    assert response.status_code == 200
    payload = response.json()
    assert payload["track"]["id"] == str(track.id)
    assert payload["track"]["story"]["id"] == str(story.id)
    assert len(payload["track_comments"]) == 1
    assert len(payload["story_comments"]) == 1


def test_create_track_comment_rejects_empty_body(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    response = client.post(f"/tracks/{track.id}/comments", json={"body": "   "})
    assert response.status_code == 400
    assert response.json()["detail"] == "Empty comment."


def test_create_track_comment_persists_comment(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    response = client.post(f"/tracks/{track.id}/comments", json={"body": "Nice track"})
    assert response.status_code == 201
    comment_payload = response.json()
    assert comment_payload["body"] == "Nice track"
    assert comment_payload["target_type"] == "track"

    stored = (
        db_session.query(models.Comment)
        .filter_by(id=UUID(comment_payload["id"]))
        .one()
    )
    assert stored.body == "Nice track"
    assert stored.target_type == models.CommentTargetType.TRACK


def test_list_tracks_includes_audio_analysis_fields(
    client: TestClient,
    db_session: Session,
) -> None:
    factories.create_track(
        db_session,
        duration_seconds=187,
        bpm=96.0,
        loudness_lufs=-12.5,
        mood_valence=0.72,
        mood_energy=0.41,
        has_vocals=True,
        tags=["chill", "focus"],
    )

    response = client.get("/tracks/")
    assert response.status_code == 200
    payload = response.json()
    assert payload, "expected at least one track"
    track = payload[0]
    assert track["duration_seconds"] == 187
    assert track["bpm"] == 96.0
    assert track["loudness_lufs"] == -12.5
    assert track["mood_valence"] == 0.72
    assert track["mood_energy"] == 0.41
    assert track["has_vocals"] is True
    assert track["tags"] == ["chill", "focus"]


def test_recommendations_surface_story_driven_tracks_for_guests(
    client: TestClient,
    db_session: Session,
) -> None:
    story_track = factories.create_track(db_session, title="Story Hero")
    story_track.like_count = 24
    story_track.view_count = 640
    story_track.created_at = datetime.utcnow()
    story = factories.create_story(
        db_session,
        track_id=story_track.id,
        author_user_id=story_track.user_id,
        lead="Lead",
        body="Body",
    )
    story.like_count = 32
    db_session.commit()
    for i in range(4):
        factories.create_comment(
            db_session,
            target_id=story.id,
            target_type=models.CommentTargetType.STORY,
            body=f"Story comment {i}",
        )
    for i in range(2):
        factories.create_comment(
            db_session,
            target_id=story_track.id,
            target_type=models.CommentTargetType.TRACK,
            body=f"Track comment {i}",
        )

    popular_but_old = factories.create_track(db_session, title="Legacy Hit")
    popular_but_old.like_count = 90
    popular_but_old.view_count = 2400
    popular_but_old.created_at = datetime.utcnow() - timedelta(days=6)
    db_session.commit()
    for i in range(3):
        factories.create_comment(
            db_session,
            target_id=popular_but_old.id,
            target_type=models.CommentTargetType.TRACK,
            body=f"Legacy comment {i}",
        )

    fresh_light = factories.create_track(db_session, title="Indie Fresh")
    fresh_light.like_count = 6
    fresh_light.view_count = 120
    db_session.commit()

    response = client.get("/tracks/recommendations?limit=3")
    assert response.status_code == 200
    payload = response.json()
    assert [item["title"] for item in payload] == [
        "Story Hero",
        "Legacy Hit",
        "Indie Fresh",
    ]


def test_recommendations_prioritize_favorite_creators_for_signed_in_user(
    client: TestClient,
    db_session: Session,
) -> None:
    creator_a = uuid4()
    creator_b = uuid4()

    liked_track = factories.create_track(db_session, user_id=creator_a, title="Old Favorite")
    db_session.add(
        models.LikeTrack(
            user_id=factories.DEFAULT_USER_ID,
            track_id=liked_track.id,
        )
    )
    liked_track.like_count = 5
    db_session.commit()

    new_from_favorite = factories.create_track(db_session, user_id=creator_a, title="Fresh Drop")
    new_from_favorite.like_count = 4
    db_session.commit()

    trending_other = factories.create_track(db_session, user_id=creator_b, title="Trending Other")
    trending_other.like_count = 55
    trending_other.view_count = 900
    db_session.commit()

    app.dependency_overrides[get_current_user_id_optional] = lambda: factories.DEFAULT_USER_ID
    try:
        response = client.get("/tracks/recommendations?limit=2")
    finally:
        app.dependency_overrides.pop(get_current_user_id_optional, None)

    assert response.status_code == 200
    payload = response.json()
    assert payload[0]["title"] == "Fresh Drop"
    assert {item["title"] for item in payload} == {"Fresh Drop", "Trending Other"}
