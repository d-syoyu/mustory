-- テストデータ投入SQL
-- PostgreSQLに直接実行してサンプルトラックを作成

-- テストユーザーを作成（既に存在する場合はスキップ）
INSERT INTO users (id, email, display_name, password_hash, created_at)
VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'demo@mustory.app',
    'Demo User',
    '$argon2id$v=19$m=65536,t=3,p=4$dummy',
    NOW()
)
ON CONFLICT (id) DO NOTHING;

-- 既存のトラックとストーリーを削除（テストデータのみ）
DELETE FROM like_tracks WHERE track_id IN (SELECT id FROM tracks WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
DELETE FROM like_stories WHERE story_id IN (SELECT id FROM stories WHERE author_user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid);
DELETE FROM comments WHERE author_user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
DELETE FROM stories WHERE author_user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;
DELETE FROM tracks WHERE user_id = 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid;

-- トラック1: Midnight Dreams (ストーリーあり)
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track001-0000-0000-0000-000000000001'::uuid,
    'Midnight Dreams',
    'Luna Eclipse',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track1/400/400',
    'https://example.com/tracks/midnight-dreams/playlist.m3u8',
    0,
    NOW()
);

INSERT INTO stories (id, track_id, author_user_id, lead, body, like_count, created_at)
VALUES (
    'story01-0000-0000-0000-000000000001'::uuid,
    'track001-0000-0000-0000-000000000001'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    '深夜の静寂の中で生まれた、幻想的なアンビエント・トラック',
    'このトラックは、深夜2時に目が覚めたときの静けさと、そこに潜む無限の可能性を表現しています。シンセサイザーの柔らかい音色と、遠くから聞こえるようなピアノのメロディーが、夢と現実の境界を曖昧にします。',
    0,
    NOW()
);

-- トラック2: Urban Pulse
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track002-0000-0000-0000-000000000002'::uuid,
    'Urban Pulse',
    'City Lights Collective',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track2/400/400',
    'https://example.com/tracks/urban-pulse/playlist.m3u8',
    0,
    NOW()
);

-- トラック3: Forest Whispers (ストーリーあり)
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track003-0000-0000-0000-000000000003'::uuid,
    'Forest Whispers',
    'Nature''s Harmony',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track3/400/400',
    'https://example.com/tracks/forest-whispers/playlist.m3u8',
    0,
    NOW()
);

INSERT INTO stories (id, track_id, author_user_id, lead, body, like_count, created_at)
VALUES (
    'story03-0000-0000-0000-000000000003'::uuid,
    'track003-0000-0000-0000-000000000003'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    '森の中で録音した自然音と、アコースティックギターの融合',
    '朝5時、地元の森に行って鳥のさえずりと風の音を録音しました。それをベースに、アコースティックギターでシンプルなメロディーを重ねています。自然との対話を音楽で表現しました。',
    0,
    NOW()
);

-- トラック4: Neon Nights (ストーリーあり)
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track004-0000-0000-0000-000000000004'::uuid,
    'Neon Nights',
    'Synth Wave 84',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track4/400/400',
    'https://example.com/tracks/neon-nights/playlist.m3u8',
    0,
    NOW()
);

INSERT INTO stories (id, track_id, author_user_id, lead, body, like_count, created_at)
VALUES (
    'story04-0000-0000-0000-000000000004'::uuid,
    'track004-0000-0000-0000-000000000004'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    '80年代のシンセウェーブに影響を受けたレトロフューチャーサウンド',
    'Miami ViceとBlade Runnerの世界観をイメージして制作しました。アナログシンセのような温かみのある音色と、リズミカルなドラムパターンが特徴です。',
    0,
    NOW()
);

-- トラック5: Coffee Shop Jazz
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track005-0000-0000-0000-000000000005'::uuid,
    'Coffee Shop Jazz',
    'The Smooth Trio',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track5/400/400',
    'https://example.com/tracks/coffee-shop-jazz/playlist.m3u8',
    0,
    NOW()
);

-- トラック6: Digital Daydream (ストーリーあり)
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track006-0000-0000-0000-000000000006'::uuid,
    'Digital Daydream',
    'Pixel Poets',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track6/400/400',
    'https://example.com/tracks/digital-daydream/playlist.m3u8',
    0,
    NOW()
);

INSERT INTO stories (id, track_id, author_user_id, lead, body, like_count, created_at)
VALUES (
    'story06-0000-0000-0000-000000000006'::uuid,
    'track006-0000-0000-0000-000000000006'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'チップチューン風の8bit サウンドと現代的なビートの融合',
    'ファミコン時代のゲーム音楽にインスパイアされて制作しました。懐かしさと新しさが共存する、デジタルな白昼夢を表現しています。',
    0,
    NOW()
);

-- トラック7: Rainy Day Reflection
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track007-0000-0000-0000-000000000007'::uuid,
    'Rainy Day Reflection',
    'Mood Melodies',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track7/400/400',
    'https://example.com/tracks/rainy-day/playlist.m3u8',
    0,
    NOW()
);

-- トラック8: Cosmic Journey (ストーリーあり)
INSERT INTO tracks (id, title, artist_name, user_id, artwork_url, hls_url, like_count, created_at)
VALUES (
    'track008-0000-0000-0000-000000000008'::uuid,
    'Cosmic Journey',
    'Star Gazers',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    'https://picsum.photos/seed/track8/400/400',
    'https://example.com/tracks/cosmic-journey/playlist.m3u8',
    0,
    NOW()
);

INSERT INTO stories (id, track_id, author_user_id, lead, body, like_count, created_at)
VALUES (
    'story08-0000-0000-0000-000000000008'::uuid,
    'track008-0000-0000-0000-000000000008'::uuid,
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::uuid,
    '宇宙の広がりと神秘を音で表現したアンビエント・スペースミュージック',
    'プラネタリウムで星空を見ながら、宇宙の無限の広がりを感じました。その感動を、シンセサイザーとドローン音を使って表現しています。',
    0,
    NOW()
);

-- 確認
SELECT COUNT(*) as track_count FROM tracks;
SELECT COUNT(*) as story_count FROM stories;
