from uuid import UUID

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
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
