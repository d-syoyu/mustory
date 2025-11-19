1. 背景・目的（Mobile First）

※大枠は v0.6 から変更なし。

モバイル単体で完結する、音楽 × 物語の創作・鑑賞の循環を提供する。

作り手が孤立せず、リスナーと創作背景が共有される場を作る。

投稿 → 再生 → 物語 → 承認 → 再訪 のループが成立する設計。

2. 想定ユーザー

※v0.6と同じ。単一アカウントで作り手／聴き手を兼ねる。

3. コア体験（MVP・モバイル）

v0.6 の以下に新規コア体験を追加：

追加コア体験：フォロー・フォローフィード（新）

フォロー（作者を追う）

トラック・物語・プロフィールからワンタップでフォロー可能。

フォローにより、作者の新曲・新物語が「フォロー中の新着」に流れる。

プッシュ通知により、新規投稿がユーザーへ届く。

フォローフィード

フォロー中のユーザーの新着トラック・新着物語を集約。

ホーム画面に「フォロー中の新着」セクションとして表示。

時系列ソート。

作者中心のコミュニティ導線

トラックから作者プロフィールへ即遷移し、フォローに繋がる。

作者軸の体験を強化し、創作継続を支える。

4. アプリ画面（MVP）

フォロー統合に伴い、以下を追加・更新する。

4.1 Profile（マイページ／他ユーザープロフィール）
目的

各ユーザーの 作品・物語・コメントを束ねるハブ。

フォロー関係の中心 UI。

共通ヘッダ構成

プロフィール画像

表示名 / @username

自己紹介文

統計サマリ（4つ）

トラック数

物語数

フォロワー数

フォロー数

タブ構成

投稿トラック

物語

いいね（公開）

コメント履歴（任意・将来拡張）

自分のマイページ（/me）

「プロフィール編集」

「設定」

通知設定・ログアウト

他ユーザーのプロフィール（/users/:id）

フォローボタン

フォローする / フォロー中

投稿トラック / 物語 / いいね

4.2 Home（更新）

Home 画面に次のセクションを追加：

「フォロー中の新着」

データ取得：GET /feed/following

表示：TrackCard / StoryCard

空のときは案内文：

まだフォローしていません。気になるユーザーのマイページからフォローしてみましょう。

5. フォロー機能（新セクション）
5.1 目的

作者との継続的な接点を持ち、創作を追える体験を作る。

レコメンド・通知・ホームフィードの個別最適化に使用する。

5.2 ユースケース

U1: A が B をフォロー → B の新曲・新物語が A のホームに表示される。

U2: フォロー数をタップ → フォロー一覧へ遷移。

U3: フォロワー数をタップ → フォロワー一覧へ遷移。

5.3 Flutter UI 要件

プロフィール画面ヘッダにフォローボタンを配置。

フォロー操作は 楽観的更新（Optimistic UI）。

ボタンの状態：

Follow

Following

6. 技術スタック（Flutter Mobile-First）

（v0.6 仕様を継続）
just_audio / audio_service / Riverpod / go_router / Dio / freezed / secure storage etc.

7. API（フォロー機能追加）
7.1 新規 API
フォロー操作

POST /follows/{user_id}

DELETE /follows/{user_id}
どちらも冪等。

フォロー一覧

GET /profiles/{id}/followers?cursor=&limit=

GET /profiles/{id}/following?cursor=&limit=

フォローフィード

GET /feed/following?cursor=&limit=

レスポンス例

[
  {
    "type": "track",
    "created_at": "...",
    "user": {...},
    "track": {...}
  },
  {
    "type": "story",
    "created_at": "...",
    "user": {...},
    "story": {...}
  }
]

プロフィール（更新）

GET /profiles/{id}

follower_count

following_count

is_followed_by_me

8. データモデル（フォロー追加）

既存モデルに追加して記述。

Follow
column	type	note
follower_id	UUID	FK → User
followee_id	UUID	FK → User
created_at	timestamp	default now

PRIMARY KEY (follower_id, followee_id)

INDEX(follower_id), INDEX(followee_id)

UserProfile 返却モデル（更新）
{
  "id": "...",
  "display_name": "...",
  "username": "...",
  "bio": "...",
  "avatar_url": "...",
  "track_count": 15,
  "story_count": 8,
  "follower_count": 89,
  "following_count": 34,
  "is_followed_by_me": true
}

9. 非機能要件（NFR）

フォロー追加による特記事項：

フォローフィード API：P95 < 300ms

フォロー操作：100ms 未満で UI が更新されること（楽観的 UI）

通知：フォロー中ユーザーの新曲・新物語投稿時に Push を送信

10. 推奨 Flutter 実装構成
10.1 Repository 層
abstract class FollowRepository {
  Future<void> follow(String userId);
  Future<void> unfollow(String userId);
  Future<List<UserSummary>> fetchFollowers(String userId);
  Future<List<UserSummary>> fetchFollowing(String userId);
  Future<List<FollowFeedItem>> fetchFollowFeed();
}

10.2 プロフィール状態管理（Riverpod）

profileProvider(userId)

ProfileController.toggleFollow()
→ 楽観的更新を実装

10.3 ルーティング（go_router）

/me

/users/:id

/profiles/:id/followers

/profiles/:id/following

11. テスト戦略（フォロー関連）

API

二重フォローが 200 OK で返る

ブロック機能追加時の整合性（将来）

Flutter

フォローボタンの楽観的更新が正しく動作する

フォロー状態がプロフィールに正しく反映される

フォローフィードが正しく時系列に並ぶ

通知

フォロー中ユーザーの新曲・新物語投稿で Push が届く

12. リリース計画（更新）

最低限の「創作ループ」に加え、以下を MVP に含める：

フォロー / フォローフィード

通知連携（新曲・新物語）

13. 将来拡張（フォロー周り）

ミュート / ブロック

フォロー推薦（グラフベース）

ユーザー検索の高度化（埋め込みモデル）

作者ごとの「月次レポート」（将来のサブスク導入を見据える）

付録：AGENTS.md との整合性

AGENTS.md（Codex 運用ガイド） と整合するように、フォロー機能に関するタスクは以下の担当範囲に割り当てる：

Mobile Agent：UI／Repository／状態管理

API Agent：エンドポイント追加・認証・ロジック

DevOps：Redis キャッシュ最適化（任意）

QA Agent：E2E（プロフィール → フォロー → 新着→通知）
