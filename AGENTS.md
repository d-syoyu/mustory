# AGENTS.md — Codex運用ガイド（音楽×物語モバイルMVP / Flutter）

本ドキュメントは、AIコーディングエージェント（以下 Codex）と人間開発者が、**同一の前提と期待値**で作業するための実務ガイドです。  
モバイル前提の要件定義 `REQUIREMENTS.md（Flutter v0.6）` と整合しています。

---

## 0. ゴール / 非ゴール

### ゴール
- Mobile-First MVP（**Flutter + FastAPI**）を、運用可能な品質で立ち上げる。
- コア体験：
  - トラック投稿（任意で物語を添付）
  - HLS ストリーミング再生（バックグラウンド対応）
  - 物語閲覧
  - トラック／物語へのコメント
  - いいね・通知

### 非ゴール
- 本番課金・投げ銭の実装（現時点では Web 側での将来対応を想定）
- 高度なレコメンド（埋め込み検索など）
- 録音支援・編集機能
- 複数クライアント（Web SPA など）の同時最適化

---

## 1. 役割（RACI）

| 役割 | 責任 | 補足 |
|------|------|------|
| **Lead Agent** | 要件→タスク分解、優先度、Definition of Done（DoD）の定義 | 人間PM兼任可 |
| **Codex** | コード実装、テストコード、簡易ドキュメント更新 | 本ドキュメントのルールに従う |
| **Human Dev** | 最終レビュー、環境構築、実機検証、リリース判断 | Git/Secrets/ストア操作など |
| **Ops/Infra** | Railway/Supabase/R2などクラウド設定 | 兼任可 |

RACI の原則：  
- Codex は「実装」と「提案」を行うが、**意思決定は常に人間側が最終責任**を持つ。  
- Codex は不確実な点を勝手に決め打ちせず、選択肢＋トレードオフを提示する。

---

## 2. リポジトリ構造（想定）

```txt
/
  apps/
    mobile/        # Flutter アプリ
    api/           # FastAPI
    worker/        # FFmpeg 等の非同期ジョブ
  packages/        # 共有ロジック（型・クライアントなど）
  infra/           # docker-compose, Railway 用設定
  analytics/       # PostHog/Sentry 等の設定
  REQUIREMENTS.md  # 要件定義（Flutter v0.6）
  AGENTS.md        # 本ファイル
```

Codex は、ファイルに触る前に**必ずリポ構造と README / REQUIREMENTS.md / 本ファイル**を確認すること。

---

## 3. ブランチ・PR・コミット規約（Codex向け）

- ブランチ名（例）：
  - `feature/mobile-track-detail-tabs`
  - `fix/api-story-permissions`
- コミットメッセージ：
  - `feat(mobile): add story/comment tabs on track detail`
  - `fix(api): restrict story edit to track owner`
- PR 説明には以下を含める：
  - 変更概要（What）
  - 背景（Why）
  - 動作確認手順（How to test）
  - 影響範囲（Impact）

Codex が出力する時点では「PR テンプレ」レベルでよく、人間側で実際の PR を作成する。

---

## 4. コーディング規約

### Flutter / Dart

- Lints:
  - `flutter_lints` もしくはそれ以上に厳しい社内ルールを前提
- 命名:
  - ファイル：`snake_case.dart`
  - クラス：`PascalCase`
  - 変数 / 関数：`lowerCamelCase`
- ディレクトリ構成（例）：

```txt
apps/mobile/lib/
  main.dart
  app/
    router.dart
    theme.dart
  features/
    track_detail/
      presentation/
        track_detail_page.dart
        widgets/
      application/
        track_detail_controller.dart
      data/
        track_detail_repository.dart
    home/
    upload/
  core/
    network/
    audio/
    models/
    analytics/
```

- 状態管理：
  - `hooks_riverpod` or `riverpod`（Provider の乱立を避ける）
- 非同期処理：
  - `Future`, `Stream` を明示し、`async` / `await` を適切に使用
- UI：
  - widget ツリーが大きくなる場合、**stateless + 小分割**を徹底

### Python（FastAPI）

- フォーマット：`ruff format` or `black`
- Lint：`ruff`
- 型：`mypy`（strict 寄り）
- API スキーマ：Pydantic v2 の `BaseModel` を使用
- 命名：
  - モジュール：`snake_case`
  - クラス：`PascalCase`
  - 関数/変数：`snake_case`

---

## 5. タスクの進め方（Codexの標準プロセス）

Codex がタスクを受け取ったら、以下の順で行動する：

1. **コンテキスト読解**
   - `REQUIREMENTS.md`
   - 関連する feature ディレクトリ（例：`features/track_detail`）
   - 既存の API クライアント / モデル
2. **タスク分解**
   - ファイル単位・責務単位でサブタスクを列挙
3. **設計方針の共有（簡潔）**
   - 「どの層を触るか」「UI/状態/API の役割分担」を文章で示す
4. **実装**
   - 型から作る（model → repository → controller → UI の順を推奨）
5. **テスト**
   - Flutter: widget テスト or unit テスト
   - API: pytest or 少なくとも curl 例
6. **自己レビュー**
   - DoD に照らしてチェックリスト形式で確認

---

## 6. モバイル実装方針（Flutter）

### ナビゲーション

- `go_router` を使用
- 代表ルート例：
  - `/` : Home
  - `/tracks/:id` : TrackDetail
  - `/upload` : UploadTrack
  - `/profile` : Profile

### 状態管理

- Riverpod で「読み取り専用の provider」「StateNotifier」「AsyncValue」等を使い分ける
- 代表的な provider：
  - `trackDetailControllerProvider(trackId)`
  - `audioPlayerControllerProvider`
  - `authStateProvider`

### オーディオ

- `just_audio` + `audio_session` + `audio_service`
- 対応：
  - HLS（m3u8）の再生
  - バックグラウンド再生
  - ロック画面/OSコントロール

### トラック詳細画面 UI（重要仕様）

`REQUIREMENTS.md v0.6` に基づく。

- 画面構成イメージ：

  - 上部：アートワーク、タイトル、アーティスト名、再生ボタン、いいね、シェア
  - 中央：**タブ or セクション切り替え**コンポーネント
    - タブ候補：`物語` / `コメント`
  - 下部：コメント一覧と入力欄

- タブ仕様：

  1. **物語タブ**
     - 表示内容：
       - 物語のリード＋本文（トラック作成者のみ編集可）
       - 物語に紐づくコメント一覧（`target_type = "story"`）
       - 物語へのコメント入力欄
     - 物語が未作成の場合：
       - トラック作成者には「物語を作成する」CTA を表示
       - 他ユーザーには「まだ物語はありません」とだけ表示

  2. **コメントタブ**
     - 表示内容：
       - トラックに紐づくコメント一覧（`target_type = "track"`）
       - トラックへのコメント入力欄

- 共通ルール：

  - 両タブとも、スクロールでコメント一覧を見た後に**すぐ投稿できる位置**に入力欄を配置
  - 非ログイン時は、入力欄の代わりに「コメントするにはログインしてください」などの CTA を表示
  - 物語の有無に関わらずコメントタブは常に有効

Codex は、この仕様を崩さないよう UI 実装・改修を行うこと。

---

## 7. API / DB 方針（ハイライト）

詳細は `REQUIREMENTS.md` を参照。ここでは Codex が特に守るべき制約のみ記載。

### 物語（Story）

- 1トラックにつき 0〜1 個
- DB制約：
  - `story.track_id` は `tracks.id` に FK
  - `story.author_user_id` は `tracks.user_id` と一致すること（アプリロジック + 制約）
- エンドポイント例：
  - `GET /tracks/{id}/story`
  - `POST /tracks/{id}/story`（トラック作成者のみ）
  - `PUT /stories/{id}` / `PATCH /stories/{id}`（同上）

Codex は、更新系エンドポイントに**認可チェック**を必ず追加すること。

### コメント（Comment）

- 単一テーブルで `target_type` + `target_id` 方式：
  - `target_type`: `"track"` or `"story"`
  - `target_id`: 対象の track.id or story.id
- エンドポイント例：
  - `GET /tracks/{id}/comments`
  - `POST /tracks/{id}/comments`
  - `GET /stories/{id}/comments`
  - `POST /stories/{id}/comments`
  - `DELETE /comments/{id}`（本人のみ）

### いいね

- `LikeTrack` / `LikeStory` / `LikeComment` の 3種を想定（コメントいいねはオプション）
- エンドポイント：
  - `POST /tracks/{id}/like` / `DELETE /tracks/{id}/like`
  - `POST /stories/{id}/like` / `DELETE /stories/{id}/like`

---

## 8. ワーカー / 媒体変換

- 目的：
  - アップロードされた音源（例：mp3/wav）を HLS 用にトランスコードする
- ツール：
  - `ffmpeg`
- 処理フロー（概要）：
  1. クライアント：プリサイン URL にアップロード
  2. API：`Track` レコード作成（status: pending）
  3. Worker：キューからジョブを取得し、HLS 変換
  4. 成功：`audio_url` & `status: ready` に更新
  5. 失敗：`status: failed` に更新
- Codex は、ワーカー側で**冪等性**（同じトラックIDで複数回実行しても破綻しない）を意識すること。

---

## 9. インフラ / CI

- インフラ：
  - Railway 上に `api`, `worker`, `postgres`, `redis`
  - Cloudflare R2 をストレージとして使用
- CI（GitHub Actions）：
  - `apps/api`: `pytest`, `mypy`, `ruff`
  - `apps/worker`: `pytest` または少なくとも Lint
  - `apps/mobile`: `flutter analyze`, `flutter test`, ビルド検証（`flutter build apk/appbundle` など）

Codex は、コード変更に合わせて必要な CI 定義（workflow yaml）の変更も提案する。

---

## 10. OpenAPI / クライアント生成

- FastAPI から `openapi.json` を生成し、将来的には Dart クライアント生成も検討
- 現時点では、手書きの API クライアント（Dio + Retrofit など）とするが、以下を守る：
  - 型はすべて明示（`Map<String, dynamic>` の乱用を避ける）
  - エラー時のレスポンスもモデル化する（エラーコード／メッセージ）

---

## 11. テスト規約

### モバイル（Flutter）

- 単体テスト：
  - ロジック部分（controller/repository）を中心に `flutter test`
- Widget テスト：
  - Track Detail 画面のタブ切り替えと表示ロジック
  - 物語未作成時 / 作成済み時
  - 未ログイン / ログイン時の入力欄表示
- Golden テストは余裕があればでよい

### API / Worker

- pytest で以下を担保：
  - 認証・認可（物語の CRUD がトラック所有者に制限されていること）
  - コメントの `target_type` / `target_id` チェック
  - ワーカージョブの成功・失敗・リトライ

---

## 12. 観測と KPI

- イベント例（PostHog 等）：
  - `play_start`
  - `story_open`
  - `track_comment_posted`
  - `story_comment_posted`
  - `notification_open`
- 追いたい指標（例）：
  - 再生 → 物語展開率
  - 再生 → トラックコメント投稿率
  - 物語閲覧 → 物語コメント投稿率

Codex は、UI を追加する際に、必要なトラッキングイベントも合わせて提案することが望ましい。

---

## 13. 付録：典型タスクテンプレ

### 13.1 Track Detail UI を改修するタスク

1. **要件整理**
   - 物語タブ／コメントタブの仕様（本ファイルおよび `REQUIREMENTS.md` を再確認）
2. **影響範囲の洗い出し**
   - `features/track_detail/presentation/`
   - `features/track_detail/application/`
   - API クライアント（コメント取得/投稿）
3. **設計**
   - タブコンポーネントの責務
   - コメントリストと入力フォームの分割
4. **実装**
   - UI → Controller → Repository の順に実装
5. **テスト**
   - タブ切り替えの widget テスト
   - API 呼び出しモックによるロジックテスト
6. **自己レビュー**
   - 要件どおりに物語コメント／トラックコメントが分かれているか
   - 未ログイン時の動作

### 13.2 新 API を追加するタスク

1. エンドポイント仕様を `REQUIREMENTS.md` に沿って確認
2. FastAPI ルータ／Pydantic モデル／DB モデルの追加・変更
3. pytest によるユニットテスト
4. OpenAPI 更新（必要なら）

---

この AGENTS.md は、Flutter 版モバイル実装および `REQUIREMENTS.md v0.6` を前提とした Codex 運用ガイドです。  
Codex は本ドキュメントと要件定義を**常にセットで参照**してタスクを遂行してください。
