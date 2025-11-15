from uuid import uuid4

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
from tests import factories


def test_create_story_requires_track_owner(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session, user_id=uuid4())

    response = client.post(
        f"/stories/track/{track.id}",
        json={"lead": "Owner lead", "body": "Owner body"},
    )

    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden."


def test_create_story_success_when_owner(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    response = client.post(
        f"/stories/track/{track.id}",
        json={"lead": "My lead", "body": "My body"},
    )
    assert response.status_code == 201
    payload = response.json()
    assert payload["track_id"] == str(track.id)
    assert payload["lead"] == "My lead"

    stored = db_session.query(models.Story).filter_by(track_id=track.id).one()
    assert stored.lead == "My lead"
    assert stored.body == "My body"


def test_cannot_create_story_if_one_already_exists(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    factories.create_story(
        db_session,
        track_id=track.id,
        author_user_id=track.user_id,
        lead="Existing lead",
        body="Existing body",
    )

    response = client.post(
        f"/stories/track/{track.id}",
        json={"lead": "Another", "body": "Should fail"},
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "Story already exists for track."
