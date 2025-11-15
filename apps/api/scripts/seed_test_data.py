#!/usr/bin/env python3
"""
テストデータ投入スクリプト

開発・デモ用にトラックのサンプルデータをデータベースに追加します。
"""

import sys
import uuid
from pathlib import Path

# プロジェクトルートをパスに追加
sys.path.insert(0, str(Path(__file__).parent.parent))

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.db.models import Track, User, Story
from app.core.config import get_settings

settings = get_settings()


def create_test_user(session: Session) -> User:
    """テストユーザーを作成または取得"""
    test_user_id = uuid.UUID("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa")

    user = session.get(User, test_user_id)
    if user:
        print(f"既存のテストユーザーを使用: {user.email}")
        return user

    user = User(
        id=test_user_id,
        email="demo@mustory.app",
        display_name="Demo User",
        password_hash="$argon2id$v=19$m=65536,t=3,p=4$dummy",  # ダミーハッシュ
    )
    session.add(user)
    session.commit()
    print(f"テストユーザーを作成: {user.email}")
    return user


def create_sample_tracks(session: Session, user: User) -> list[Track]:
    """サンプルトラックを作成"""

    # 既存のトラックを確認
    existing_count = session.query(Track).count()
    if existing_count > 0:
        print(f"既に{existing_count}件のトラックが存在します。")
        response = input("既存のトラックを削除して新しいデータを作成しますか？ (y/N): ")
        if response.lower() != 'y':
            print("処理を中断しました。")
            return []

        # 既存データを削除
        session.query(Story).delete()
        session.query(Track).delete()
        session.commit()
        print("既存のトラックとストーリーを削除しました。")

    # サンプルトラックデータ
    sample_tracks = [
        {
            "title": "Midnight Dreams",
            "artist_name": "Luna Eclipse",
            "artwork_url": "https://picsum.photos/seed/track1/400/400",
            "hls_url": "https://example.com/tracks/midnight-dreams/playlist.m3u8",
            "has_story": True,
            "story": {
                "lead": "深夜の静寂の中で生まれた、幻想的なアンビエント・トラック",
                "body": "このトラックは、深夜2時に目が覚めたときの静けさと、そこに潜む無限の可能性を表現しています。シンセサイザーの柔らかい音色と、遠くから聞こえるようなピアノのメロディーが、夢と現実の境界を曖昧にします。",
            }
        },
        {
            "title": "Urban Pulse",
            "artist_name": "City Lights Collective",
            "artwork_url": "https://picsum.photos/seed/track2/400/400",
            "hls_url": "https://example.com/tracks/urban-pulse/playlist.m3u8",
            "has_story": False,
        },
        {
            "title": "Forest Whispers",
            "artist_name": "Nature's Harmony",
            "artwork_url": "https://picsum.photos/seed/track3/400/400",
            "hls_url": "https://example.com/tracks/forest-whispers/playlist.m3u8",
            "has_story": True,
            "story": {
                "lead": "森の中で録音した自然音と、アコースティックギターの融合",
                "body": "朝5時、地元の森に行って鳥のさえずりと風の音を録音しました。それをベースに、アコースティックギターでシンプルなメロディーを重ねています。自然との対話を音楽で表現しました。",
            }
        },
        {
            "title": "Neon Nights",
            "artist_name": "Synth Wave 84",
            "artwork_url": "https://picsum.photos/seed/track4/400/400",
            "hls_url": "https://example.com/tracks/neon-nights/playlist.m3u8",
            "has_story": True,
            "story": {
                "lead": "80年代のシンセウェーブに影響を受けたレトロフューチャーサウンド",
                "body": "Miami ViceとBlade Runnerの世界観をイメージして制作しました。アナログシンセのような温かみのある音色と、リズミカルなドラムパターンが特徴です。",
            }
        },
        {
            "title": "Coffee Shop Jazz",
            "artist_name": "The Smooth Trio",
            "artwork_url": "https://picsum.photos/seed/track5/400/400",
            "hls_url": "https://example.com/tracks/coffee-shop-jazz/playlist.m3u8",
            "has_story": False,
        },
        {
            "title": "Digital Daydream",
            "artist_name": "Pixel Poets",
            "artwork_url": "https://picsum.photos/seed/track6/400/400",
            "hls_url": "https://example.com/tracks/digital-daydream/playlist.m3u8",
            "has_story": True,
            "story": {
                "lead": "チップチューン風の8bit サウンドと現代的なビートの融合",
                "body": "ファミコン時代のゲーム音楽にインスパイアされて制作しました。懐かしさと新しさが共存する、デジタルな白昼夢を表現しています。",
            }
        },
        {
            "title": "Rainy Day Reflection",
            "artist_name": "Mood Melodies",
            "artwork_url": "https://picsum.photos/seed/track7/400/400",
            "hls_url": "https://example.com/tracks/rainy-day/playlist.m3u8",
            "has_story": False,
        },
        {
            "title": "Cosmic Journey",
            "artist_name": "Star Gazers",
            "artwork_url": "https://picsum.photos/seed/track8/400/400",
            "hls_url": "https://example.com/tracks/cosmic-journey/playlist.m3u8",
            "has_story": True,
            "story": {
                "lead": "宇宙の広がりと神秘を音で表現したアンビエント・スペースミュージック",
                "body": "プラネタリウムで星空を見ながら、宇宙の無限の広がりを感じました。その感動を、シンセサイザーとドローン音を使って表現しています。",
            }
        },
    ]

    tracks = []
    for track_data in sample_tracks:
        # トラックを作成
        track = Track(
            id=uuid.uuid4(),
            title=track_data["title"],
            artist_name=track_data["artist_name"],
            user_id=user.id,
            artwork_url=track_data["artwork_url"],
            hls_url=track_data["hls_url"],
            like_count=0,
        )
        session.add(track)
        session.flush()  # IDを取得するためにflush

        # ストーリーがある場合は作成
        if track_data.get("has_story") and "story" in track_data:
            story = Story(
                id=uuid.uuid4(),
                track_id=track.id,
                author_user_id=user.id,
                lead=track_data["story"]["lead"],
                body=track_data["story"]["body"],
                like_count=0,
            )
            session.add(story)

        tracks.append(track)
        print(f"  + {track.title} by {track.artist_name}")

    session.commit()
    print(f"\n{len(tracks)}件のトラックを作成しました。")
    return tracks


def main():
    """メイン処理"""
    print("=" * 60)
    print("Mustory テストデータ投入スクリプト")
    print("=" * 60)
    print()

    # データベース接続
    engine = create_engine(settings.database_url)

    with Session(engine) as session:
        # テストユーザーを作成
        print("1. テストユーザーを作成...")
        user = create_test_user(session)
        print()

        # サンプルトラックを作成
        print("2. サンプルトラックを作成...")
        tracks = create_sample_tracks(session, user)
        print()

    print("=" * 60)
    print("完了！")
    print(f"API URL: http://localhost:8000/tracks")
    print(f"作成されたトラック数: {len(tracks)}")
    print("=" * 60)


if __name__ == "__main__":
    main()
