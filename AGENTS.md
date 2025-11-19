# AGENTS.md — Codex運用ガイド（音楽×物語モバイルMVP / Flutter）

本ドキュメントは、AIコーディングエージェント（以下 Codex）と人間開発者が、**同じ前提と期待値**を共有するための実務ガイドである。  
モバイル要件は Flutter 版 `REQUIREMENTS.md v0.6` をソース・オブ・トゥルースとし、Flutter をコアクライアント、FastAPI をバックエンド、Worker を非同期処理として磨き込む。

---

## 0. ゴール / 非ゴール

### ゴール
- Mobile-First MVP（**Flutter + FastAPI + Worker**）を、運用可能な品質で立ち上げる。
- コア体験：
  - トラック投稿（任意で物語を添付）
  - HLS ストリーミング再生（バックグラウンド対応）
  - 物語閲覧
  - トラック／物語へのコメント
  - いいね・通知

### 非ゴール
- 本番課金・投げ銭（現時点では Web 側での将来対応を想定）
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

## 2. リポジトリ構造（現状）

```txt
/
  apps/
    mobile/        # Flutter アプリ（MVPの主戦場）
    api/           # FastAPI
    worker/        # FFmpeg 等の非同期ジョブ
  packages/        # 共有ロジック（型・クライアントなど）
  infra/           # docker-compose, Railway 用設定
  analytics/       # PostHog/Sentry 等の設定
  REQUIREMENTS.md  # Flutter v0.6 要件（UI仕様の参照元）
  AGENTS.md        # 本ファイル
  BACKGROUND_AUDIO_IMPLEMENTATION.md
  UPLOAD_IMPLEMENTATION_PROGRESS.md
  UI_IMPROVEMENTS_SUMMARY.md
  BUILD_SUCCESS_REPORT.md / INTEGRATION_TEST_REPORT.md
```

Codex は作業前に **README / REQUIREMENTS.md / 本ファイル** を確認し、関連する進捗ドキュメント（例：`UPLOAD_IMPLEMENTATION_PROGRESS.md`）を必要に応じて参照すること。

---

## 3. ブランチ・PR・コミット規約（Codex向け）

- ブランチ名（例）：
  - `feature/flutter-track-detail-tabs`
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
- Flutter 3.24+ / Dart 3.5+ を前提とする。
- `analysis_options.yaml` は `lints` + プロジェクト独自ルールで Warning=Error を維持。
- 状態管理は **hooks_riverpod**（または riverpod + StateNotifier）で統一し、`lib/app/providers.dart` にエントリーポイントを集約。
- HTTP クライアントは `dio`、HLS再生などの低レイヤー API 接続は `core` 配下でカプセル化。
- 依存注入：`ProviderScope` + `ProviderContainer` を介して行い、`get_it` の追加導入は避ける。
- 非同期処理は `Future`/`Stream` + `async/await` を徹底し、Bloc/Redux等の併用は禁止。
- フォーマット：`flutter format .` / `dart format .` を使用。自動整形設定を有効化。
- テスト：`flutter test --coverage` を基本とし、ウィジェットテストでタブ切り替えやコメント投稿 UI を担保。
- ディレクトリ構成（例）：

```txt
lib/
  app/          # ルーター、テーマ、DI
  core/         # APIクライアント、認証、オーディオ、分析
  features/
    track_detail/
      data/
      application/
      presentation/
    upload/
    home/
  shared/       # 共通UI・utils
```

### Python（FastAPI）
- フォーマット：`ruff format` or `black`
- Lint：`ruff`
- 型：`mypy`（strict 寄り）
- API スキーマ：Pydantic v2 の `BaseModel`
- 命名：
  - モジュール：`snake_case`
  - クラス：`PascalCase`
  - 関数/変数：`snake_case`

---

## 5. タスクの進め方（Codex標準プロセス）

1. **コンテキスト読解**
   - `REQUIREMENTS.md (v0.6)` と関連ドキュメントを確認
   - 対象 feature ディレクトリと関連 API クライアントを読む
2. **タスク分解**
   - ファイル単位・責務単位でサブタスクを列挙
3. **設計方針の共有**
   - 「どの層を触るか」「UI/状態/API の役割分担」を短く記述
4. **実装**
   - 型定義 → API クライアント → application 層 → presentation 層の順を推奨
5. **テスト**
   - `flutter test` or `pytest` で対象層に応じたテストを追加
6. **自己レビュー**
   - DoD の観点でチェックリスト化し、diff を見ながら検証

---

## 6. モバイル実装方針（Flutter）

### ナビゲーション
- `GoRouter` を採用。ルート例：
  - `/` : Home / Feed
  - `/tracks/:id` : TrackDetail（タブ UI）
  - `/upload` : UploadTrack
  - `/profile` : Profile / Settings
- Deeplink / push 通知からの遷移は `GoRouter` の `redirect` で制御し、`app_router.dart` にまとめる。

### 状態管理
- Riverpod の `AsyncNotifier` / `StateNotifier` でサーバー状態を包む。
- オーディオプレーヤー状態は `audioPlayerControllerProvider` で一元管理。
- `ref.invalidate` を積極的に使い、コメント投稿後の再取得などを徹底。

### オーディオ
- `just_audio` + `audio_service` + `audio_session` を基礎とし、`BACKGROUND_AUDIO_IMPLEMENTATION.md` の方針に従う。
- 対応事項：
  - HLS（m3u8）再生
  - バックグラウンド再生（Android Foreground Service, iOS Background Modes）
  - ロック画面 / OS コントロール
  - 通知コントロール（次へ / 前へ / 再生 / 一時停止）
- `core/audio/` で AudioHandler・controller を提供し、UI からはフック経由で操作する。

### トラック詳細画面 UI（Flutter仕様）
`REQUIREMENTS.md v0.6` の要件を守る：
1. **ヘッダー**：アートワーク、タイトル、アーティスト名、再生ボタン、いいね、シェア
2. **中央：タブ切り替え**：`物語` / `コメント`
3. **物語タブ**：本文、物語コメント一覧（`target_type = "story"`）、コメント入力欄。物語なし時のCTA
4. **コメントタブ**：トラックコメント一覧（`target_type = "track"`）、入力欄
5. **共通**：コメント入力欄は一覧直下。未ログイン時はCTA表示。物語の有無に関わらずコメントタブは常に有効

Flutter では `TabBarView` + `SliverAppBar` を使った実装を推奨。Widget テストでタブ切り替えやログイン状態別表示を確認する。

---

## 7. API / DB 方針（抜粋）

`REQUIREMENTS.md` を詳細仕様として参照。特に以下を厳守：

### 物語（Story）
- 1 トラックにつき 0〜1 個
- `story.track_id` → `tracks.id` FK、`story.author_user_id` は `tracks.user_id` と一致
- エンドポイント：
  - `GET /tracks/{id}/story`
  - `POST /tracks/{id}/story`（トラック作成者のみ）
  - `PUT /stories/{id}` / `PATCH /stories/{id}`（同上）

### コメント（Comment）
- 単一テーブルで `target_type` + `target_id`
  - `target_type`: `"track"` or `"story"`
  - `target_id`: 対象の track.id / story.id
- エンドポイント例：
  - `GET /tracks/{id}/comments`
  - `POST /tracks/{id}/comments`
  - `GET /stories/{id}/comments`
  - `POST /stories/{id}/comments`
  - `DELETE /comments/{id}`（本人のみ）

### いいね
- `LikeTrack` / `LikeStory` / `LikeComment`
- エンドポイント例：
  - `POST /tracks/{id}/like` / `DELETE /tracks/{id}/like`
  - `POST /stories/{id}/like` / `DELETE /stories/{id}/like`

---

## 8. ワーカー / 媒体変換

- 目的：アップロードされた音源を HLS 用にトランスコード
- ツール：`ffmpeg`
- 処理フロー：
  1. クライアント：プリサイン URL にアップロード
  2. API：`Track` レコード作成（status: pending）
  3. Worker：ジョブを取得し HLS 変換
  4. 成功：`audio_url` & `status: ready` に更新
  5. 失敗：`status: failed`
- 冪等性（同じトラック ID で複数回実行しても破綻しない）を意識すること
- 進捗更新は `UPLOAD_IMPLEMENTATION_PROGRESS.md` をソースにし、実装との差分は適宜更新する。

---

## 9. インフラ / CI

- インフラ：
  - Railway 上に `api`, `worker`, `postgres`, `redis`
  - Cloudflare R2 をストレージとして使用
- CI（GitHub Actions）：
  - `apps/api`: `pytest`, `mypy`, `ruff`
  - `apps/worker`: `pytest` or lint
  - `apps/mobile`: `flutter analyze`, `flutter test`, `flutter build ipa/apk --config-only` など
- Codex はコード変更に合わせて CI workflow の更新も提案する。

---

## 10. OpenAPI / クライアント生成

- FastAPI から `openapi.json` を生成
- 参照実装として `apps/mobile/lib/core/api` 内に Dio ベースのクライアントを手書きしている
- ルール：
  - 型はすべて明示（`Map<String, dynamic>` の乱用禁止）
  - エラー時のレスポンスもモデル化し、アプリ側でハンドリングする

---

## 11. テスト規約

### モバイル（Flutter）
- 単体テスト：StateNotifier や repository を `flutter test` で検証
- ウィジェットテスト：`test/features/...` でタブ切り替えやコメント UI をテスト
- シナリオテスト：`integration_test/` にアップロードフロー / オーディオ再生ケースを追加
- 将来の E2E：`flutter drive` or `Maestro` を検討

### API / Worker
- pytest で以下を担保：
  - 認証・認可（物語 CRUD がトラック所有者に制限されること）
  - コメントの `target_type` / `target_id` チェック
  - ワーカージョブの成功・失敗・リトライ

---

## 12. 観測と KPI

- 計測イベント例（PostHog 等）：
  - `play_start`
  - `story_open`
  - `track_comment_posted`
  - `story_comment_posted`
  - `notification_open`
- 追いたい指標：
  - 再生 → 物語展開率
  - 再生 → トラックコメント投稿率
  - 物語閲覧 → 物語コメント投稿率

UI を追加する際は、必要なトラッキングイベントも合わせて提案することが望ましい。

---

## 13. 付録：典型タスクテンプレ

### 13.1 Track Detail UI を改修するタスク
1. **要件整理**：`REQUIREMENTS.md` の物語タブ／コメントタブ仕様を再確認
2. **影響範囲の洗い出し**：`apps/mobile/lib/features/track_detail`、状態管理、API クライアント
3. **設計**：`TabController`/`GoRouter` の責務、コメントリストと入力フォームの分割方針
4. **実装**：data → application → presentation → widget tests の順に実装
5. **テスト**：Riverpod provider のユニットテスト + Widget テスト
6. **自己レビュー**：ログイン状態や空データ時のハンドリングを確認

### 13.2 新 API を追加するタスク
1. エンドポイント仕様を `REQUIREMENTS.md` と設計資料で確認
2. FastAPI ルータ／Pydantic モデル／DB モデルの追加・変更
3. pytest によるユニットテスト
4. OpenAPI を更新し、Flutter 側 Dio クライアントを同期

---

本ガイドは Flutter ベースのモバイル実装を前提とし、既存の FastAPI / Worker / インフラと歩調を合わせるためのもの。  
Codex は `REQUIREMENTS.md` と進捗レポートを常に同期させ、**Flutter 版こそが本線**であることを忘れずに行動すること。
