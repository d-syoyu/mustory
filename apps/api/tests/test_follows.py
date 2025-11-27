from uuid import UUID, uuid4

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.db import models
from tests.factories import create_story, create_track


def _create_user(session: Session, *, user_id: UUID | None = None, email: str = "target@example.com") -> models.User:
    user = models.User(
        id=user_id or uuid4(),
        email=email,
        display_name="Target User",
        password_hash="hash",
    )
    session.add(user)
    session.commit()
    return user


def test_follow_and_unfollow_flow(client: TestClient, db_session: Session) -> None:
    target_user = _create_user(db_session)

    # follow
    res = client.post(f"/follows/{target_user.id}")
    assert res.status_code == 200
    assert res.json()["success"] is True
    assert res.json()["follower_count"] == 1

    # profile reflects follow status
    profile_res = client.get(f"/profiles/{target_user.id}")
    assert profile_res.status_code == 200
    body = profile_res.json()
    assert body["follower_count"] == 1
    assert body["is_followed_by_me"] is True

    # followers list contains current user
    followers_res = client.get(f"/profiles/{target_user.id}/followers")
    assert followers_res.status_code == 200
    followers = followers_res.json()
    assert len(followers) == 1
    assert followers[0]["id"] == "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"

    # unfollow
    unfollow_res = client.delete(f"/follows/{target_user.id}")
    assert unfollow_res.status_code == 200
    assert unfollow_res.json()["follower_count"] == 0

    # profile reflects unfollow
    profile_res = client.get(f"/profiles/{target_user.id}")
    body = profile_res.json()
    assert body["follower_count"] == 0
    assert body["is_followed_by_me"] is False


def test_follow_self_returns_400(client: TestClient) -> None:
    res = client.post("/follows/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")
    assert res.status_code == 400
    assert res.json()["detail"] == "Cannot follow yourself"


def test_following_feed_includes_tracks_and_stories(client: TestClient, db_session: Session) -> None:
    target_user = _create_user(db_session, email="creator@example.com")

    track = create_track(db_session, user_id=target_user.id, title="Feed Track")
    create_story(
        db_session,
        track_id=track.id,
        author_user_id=target_user.id,
        lead="Lead",
        body="Body",
    )

    # Follow the creator to see their content in feed
    follow_res = client.post(f"/follows/{target_user.id}")
    assert follow_res.status_code == 200

    feed_res = client.get("/feed/following")
    assert feed_res.status_code == 200
    items = feed_res.json()

    # Expect both track and story from the followed user
    types = sorted(item["type"] for item in items)
    assert types == ["story", "track"]
    user_ids = {item["user"]["id"] for item in items}
    assert user_ids == {str(target_user.id)}
