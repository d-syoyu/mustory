from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
from tests import factories


def test_like_track_creates_like_and_increments_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    initial_count = track.like_count

    response = client.post(f"/tracks/{track.id}/like")
    assert response.status_code == 201
    assert response.json()["message"] == "Track liked successfully."

    db_session.refresh(track)
    assert track.like_count == initial_count + 1

    # Verify like record exists
    like = db_session.query(models.LikeTrack).filter_by(track_id=track.id).first()
    assert like is not None


def test_like_track_rejects_duplicate_like(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    # First like
    response = client.post(f"/tracks/{track.id}/like")
    assert response.status_code == 201

    # Duplicate like
    response = client.post(f"/tracks/{track.id}/like")
    assert response.status_code == 400
    assert response.json()["detail"] == "Track already liked."


def test_unlike_track_removes_like_and_decrements_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    # Like first
    client.post(f"/tracks/{track.id}/like")
    db_session.refresh(track)
    count_after_like = track.like_count

    # Unlike
    response = client.delete(f"/tracks/{track.id}/like")
    assert response.status_code == 200
    assert response.json()["message"] == "Track unliked successfully."

    db_session.refresh(track)
    assert track.like_count == count_after_like - 1

    # Verify like record is deleted
    like = db_session.query(models.LikeTrack).filter_by(track_id=track.id).first()
    assert like is None


def test_unlike_track_returns_404_when_not_liked(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)

    response = client.delete(f"/tracks/{track.id}/like")
    assert response.status_code == 404
    assert response.json()["detail"] == "Like not found."


def test_like_story_creates_like_and_increments_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    story = factories.create_story(
        db_session,
        track_id=track.id,
        author_user_id=track.user_id,
    )
    initial_count = story.like_count

    response = client.post(f"/stories/{story.id}/like")
    assert response.status_code == 201
    assert response.json()["message"] == "Story liked successfully."

    db_session.refresh(story)
    assert story.like_count == initial_count + 1


def test_like_story_rejects_duplicate_like(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    story = factories.create_story(
        db_session,
        track_id=track.id,
        author_user_id=track.user_id,
    )

    # First like
    response = client.post(f"/stories/{story.id}/like")
    assert response.status_code == 201

    # Duplicate like
    response = client.post(f"/stories/{story.id}/like")
    assert response.status_code == 400
    assert response.json()["detail"] == "Story already liked."


def test_unlike_story_removes_like_and_decrements_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    story = factories.create_story(
        db_session,
        track_id=track.id,
        author_user_id=track.user_id,
    )

    # Like first
    client.post(f"/stories/{story.id}/like")
    db_session.refresh(story)
    count_after_like = story.like_count

    # Unlike
    response = client.delete(f"/stories/{story.id}/like")
    assert response.status_code == 200
    assert response.json()["message"] == "Story unliked successfully."

    db_session.refresh(story)
    assert story.like_count == count_after_like - 1


def test_like_comment_creates_like_and_increments_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    comment = factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Great track!",
    )
    initial_count = comment.like_count

    response = client.post(f"/comments/{comment.id}/like")
    assert response.status_code == 201
    assert response.json()["message"] == "Comment liked successfully."

    db_session.refresh(comment)
    assert comment.like_count == initial_count + 1


def test_like_comment_rejects_duplicate_like(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    comment = factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Great track!",
    )

    # First like
    response = client.post(f"/comments/{comment.id}/like")
    assert response.status_code == 201

    # Duplicate like
    response = client.post(f"/comments/{comment.id}/like")
    assert response.status_code == 400
    assert response.json()["detail"] == "Comment already liked."


def test_unlike_comment_removes_like_and_decrements_count(
    client: TestClient,
    db_session: Session,
) -> None:
    track = factories.create_track(db_session)
    comment = factories.create_comment(
        db_session,
        target_id=track.id,
        target_type=models.CommentTargetType.TRACK,
        body="Great track!",
    )

    # Like first
    client.post(f"/comments/{comment.id}/like")
    db_session.refresh(comment)
    count_after_like = comment.like_count

    # Unlike
    response = client.delete(f"/comments/{comment.id}/like")
    assert response.status_code == 200
    assert response.json()["message"] == "Comment unliked successfully."

    db_session.refresh(comment)
    assert comment.like_count == count_after_like - 1
