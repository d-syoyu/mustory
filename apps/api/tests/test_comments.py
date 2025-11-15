from uuid import UUID, uuid4

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
from tests import factories


def test_delete_comment_marks_record_deleted(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    comment = factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Remove me",
    )

    response = client.delete(f"/comments/{comment.id}")

    assert response.status_code == 204
    db_session.refresh(comment)
    assert comment.is_deleted


def test_delete_comment_fails_for_non_author(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    comment = factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Wrong author",
        author_user_id=uuid4(),
    )

    response = client.delete(f"/comments/{comment.id}")
    assert response.status_code == 403
    assert response.json()["detail"] == "Forbidden."


def test_delete_comment_returns_404_when_missing(
    client: TestClient,
    db_session: Session,
) -> None:
    response = client.delete(f"/comments/{UUID(int=1)}")
    assert response.status_code == 404
