# インディー音楽発見プラットフォーム 要件定義書（Flutterモバイルアプリ前提 v0.6）

## 1. 背景・目的（Mobile First）

### 課題
- 音楽を聴く場は豊富だが、作り手が孤立しやすい。
- アマチュア／素人音楽家が**スマホ中心**の生活動線で作品と物語を安全に共有できる場が不足。
- モバイル環境では投稿・再生・反応の摩擦（通信・バッテリー・通知設計）が創作持続を阻害。

### 目的・価値
- **モバイル単体で完結**する「投稿 → 再生 → 物語 → 承認」の循環を提供。
- 音楽とそれに紐づく**物語（創作背景・解釈）**を一次コンテンツとして扱い、リスナーを創作の輪に巻き込む。
- 移動中・スキマ時間でも**低摩擦**で創作・鑑賞・交流が続く体験を実現。
- 物語は**トラックの作成者だけが投稿できる公式な「作品の背景・解説」**とし、
  - それに対するリスナーの反応はコメントとして扱う。
  - さらに、**トラック本体に対するコメント**も許可し、「曲そのものへの感想」と「物語への感想」を両方受け止める。

---

## 2. 想定ユーザー

- **アーティスト**
  - スマホで録音／ミックス済み音源をアップし、物語（公式ストーリー）を添えて発表する。
- **リスナー**
  - ストリーミングで再生し、物語を読んだうえで**トラック／物語の両方にコメントで反応**する。
  - 気が向いたときに自分もトラックを投稿することでアーティスト側に回ることができる。
- **単一アカウントで双方を担う**
  - アカウント種別やロール区別は設けず、ログインユーザーは誰でも投稿・再生・リアクションを行える。
  - 両者の役割は循環的に入れ替わる。

---

## 3. コア体験（MVP・モバイル）

1. **曲の発見**
   - ホームのカード一覧（再生数／いいね数／コメント数／物語有無など）。
2. **再生（メイン体験）**
   - バックグラウンド再生・ロック画面コントロール対応。
3. **物語を読む**
   - 曲詳細で、トラック作成者による公式な物語（1トラックにつき 0〜1 件）をリード表示 → 全文展開。
   - 物語がないトラックでは、「物語を追加する」導線はトラック作成者にのみ見せる。
4. **コメントを書く**
   - トラック詳細画面では、**物語・コメントをタブ or セクション切り替えで表示**し、
     - 「物語」タブ／セクション：物語本文＋物語へのコメント一覧＋物語へのコメント投稿欄
     - 「コメント」タブ／セクション：トラックへのコメント一覧＋トラックへのコメント投稿欄
   - どちらのタブ／セクションからも、その対象に対してすぐコメントできる UI とする。
5. **リアクション**
   - 曲・物語・コメントへの「いいね」。
   - すべてのコンテンツ（トラック、物語、コメント）に対していいね機能を実装。
6. **投稿**
   - 音源アップロード（タイトル／タグ／カバー／任意で物語）。
   - トラック作成者だけが物語を作成・更新できる（サーバ側でトラック所有者をチェック）。
7. **通知**
   - フォローしているトラック／物語／コメントの更新やおすすめをプッシュ通知で届け、開封イベントを分析基盤に送信。
8. **おすすめ（レコメンド）**
   - Spotify / Apple Music / YouTube Music などモダンな主要ストリーミングサービスが実装している協調フィルタリング・埋め込みモデル・行動ログ解析ベースのおすすめアルゴリズムを取り込み、ユーザーごとの個別キュレーションを提供する。
   - MVP ではバックエンド側に将来のモデル改善を容易にする API / データ構造を用意し、段階的にアルゴリズム精度を高められる設計とする。

---

## 4. アプリ画面（MVP）

- **Home**
  - 新着・注目タブ。
  - カード：カバー、タイトル、制作者名、メタ統計
    - 再生数／トラックコメント数／物語コメント数／いいね数／物語有無
    - コメント数は「合計」または「トラック＋物語」のどちらかを表示（実装時に決定）。
  - おすすめアルゴリズムが算出した「あなた向け」リストを最上部に配置し、ユーザーごとの嗜好に合わせた曲を優先的に提示。

- **Track Detail**
  - プレイヤー（シークバーまたは波形風 UI）。
  - いいね、シェアボタン。
  - 上部にタブ or 同一画面内に明確なセクションで切り替え可能な UI を配置：
    - **物語タブ／セクション**
      - 物語のリード＋全文表示。
      - 物語に紐づくコメント一覧（Story Comments）。
      - 物語へのコメント投稿欄。
      - トラック作成者には「物語を作成／編集」ボタンを表示（物語未作成時／既存時）。
    - **コメントタブ／セクション**
      - トラックに紐づくコメント一覧（Track Comments）。
      - トラックへのコメント投稿欄。
  - タブ／セクションの切り替えはワンタップで行え、どちらもスクロール量に関わらずコメント入力まで辿り着きやすい設計とする。

- **Story Feed**
  - 最新の物語フィード（トラック横断で、アーティストのストーリー更新を追える画面）。
  - 各カードから Track Detail に遷移し、「物語」タブ／セクションを前面にして表示。

- **Upload Track**
  - 音源（<=100MB）、タイトル、タグ、カバー画像。
  - 任意で物語（リード + 本文）を同時作成可能。

- **Edit Story**
  - トラック作成者専用の物語編集画面。
  - リード（必須・120字上限）、本文（任意・2000字上限）。

- **Comments**
  - Track Detail 内のタブ／セクションとして完結させる前提のため、単独画面は必須ではない。
  - 将来的に「自分のコメント一覧」などを Profile 配下に追加することは想定。

- **Profile**
  - 自分の曲一覧、物語付きトラック一覧、コメント履歴、いいね履歴、設定。

- **Auth**
  - サインアップ／ログイン（メール＋パスワード）。

- **Report**
  - 通報モーダル（対象種別／理由／送信）。

- **Player Mini Bar（常駐）**
  - 再生／一時停止、簡易シーク、曲タイトル表示、Track Detail への導線。

---

## 5. 技術スタック（Flutter Mobile-First）

### モバイルアプリ（Flutter）

- **フレームワーク**
  - Flutter（最新安定版、Dart）
- **アーキテクチャ／状態管理**
  - Riverpod（または hooks_riverpod）をベースとした状態管理。
  - `data` / `repository` / `service` / `ui`（presentation）構成。
- **ルーティング**
  - go_router（Deep Link / Dynamic Link 対応しやすいルーター）。
- **HTTP / API クライアント**
  - Dio + Retrofit もしくは Dio + hand-written client。
- **JSON シリアライズ**
  - json_serializable + freezed（イミュータブルモデル＆sealedクラス）。
- **ローカル保存**
  - Hive もしくは shared_preferences。
- **オーディオ再生**
  - just_audio + audio_session。
  - audio_service と連携してバックグラウンド再生／ロック画面コントロール対応。
  - HLS（m3u8）の再生に対応できるよう、対応プレイヤー／プラグインを選定。
- **通知**
  - Firebase Cloud Messaging（firebase_messaging）。
  - flutter_local_notifications と連携してフォアグラウンド通知表示。
- **認証情報の安全な保存**
  - flutter_secure_storage（Keychain/Keystore）。
- **ディープリンク／アプリリンク**
  - Firebase Dynamic Links or native deep link 設定。
- **ビルド・配信**
  - `flutter build ios` / `flutter build appbundle`。
  - GitHub Actions + Fastlane or Codemagic による CI/CD。
  - TestFlight / Google Play Internal Testing 経由で β 配信。

### バックエンド（概要）

- **API**：FastAPI（Python 3.12）
  - ランタイム：Uvicorn + Gunicorn
  - ORM：SQLAlchemy 2.x + Alembic
  - バリデーション：Pydantic v2
  - 認証：短命 JWT + Refresh トークン、argon2id ハッシュ
- **DB**：PostgreSQL 16
  - 検索：Postgres FTS（将来 Meilisearch 拡張）
- **キャッシュ／ジョブ**
  - Redis + RQ（または Celery）
- **ストレージ**
  - S3 互換ストレージ（Cloudflare R2）
  - アップロード方式：プリサイン URL（事前認可 PUT）
- **音声配信**
  - HLS（m3u8 + ts/aac）
  - FFmpeg で 96/160 kbps 変換 → R2 → Cloudflare CDN 配信
- **監視・分析**
  - Sentry（クラッシュ監視）
  - PostHog などの行動分析基盤

### インフラ

- **ホスティング**
  - Railway（API、ワーカー、DB、Redis）
- **CI/CD**
  - GitHub Actions
    - API/Worker：pytest/mypy/ruff
    - Mobile：`flutter test` / `flutter analyze` / `flutter build`（少なくともビルド検証）
  - ストア配信用に Fastlane 実行 or Codemagic 連携。
- **Secrets 管理**
  - Doppler or 1Password CLI（`.env` / `local.properties` / `xcconfig` 等は Git 無追跡）

---

## 6. 非機能要件（NFR・モバイル特化）

- **可用性**
  - 99.5% 稼働を目標。
- **性能**
  - アプリコールドスタート：< 2.5 秒
  - API P95：< 300 ms
  - 再生開始：< 800 ms（HLS プレイリスト取得〜再生開始まで）
- **バッテリー／データ**
  - ビットレート選択（モバイルデータ時は低ビットレート優先）を検討。
  - バックグラウンドオーディオ時の CPU ウェイクを最小化。
- **信頼性**
  - アップロード再開・リトライ（モバイル回線断を考慮）。
  - 冪等なアップロード API 設計。
- **セキュリティ**
  - TLS 強制。
  - 短命 JWT + Refresh、トークンは secure storage に保存。
  - PII マスク、ログには機微情報を残さない。
- **アクセシビリティ**
  - フォントサイズ可変、コントラスト確保。
  - TalkBack / VoiceOver 対応（アイコンにラベル付与）。
- **アプリサイズ**
  - < 100 MB（理想 50 MB 前後）を目標。
- **対象 OS**
  - iOS 16+
  - Android 9+

---

## 7. API 概要（MVP）

### 認証

- `POST /auth/signup`
- `POST /auth/login`
- `POST /auth/token/refresh`

### 曲

- `GET /tracks`
- `POST /tracks`
- `GET /tracks/{id}`
- `POST /tracks/{id}/like`
- `DELETE /tracks/{id}/like`

### 物語（トラック作成者専用）

- `GET /tracks/{id}/story`  
  - 指定トラックの物語（0 or 1 件）を取得。
- `POST /tracks/{id}/story`  
  - トラック作成者のみ作成可能。既に物語がある場合は 409 or PUT 相当。
- `PUT /stories/{id}` or `PATCH /stories/{id}`  
  - トラック作成者のみ更新可能。
- `POST /stories/{id}/like`
- `DELETE /stories/{id}/like`

### 物語フィード

- `GET /stories/feed`
  - 新着 or 人気の物語一覧を取得（カードから Track Detail へ遷移）。

### コメント（トラック／物語両方）

設計方針として、**単一 Comment モデル + target_type/target_id** で表現する。

- トラックへのコメント
  - `GET /tracks/{id}/comments`
  - `POST /tracks/{id}/comments`
- 物語へのコメント
  - `GET /stories/{id}/comments`
  - `POST /stories/{id}/comments`
- 共通操作
  - `DELETE /comments/{id}`（自分のコメントのみ）
  - `POST /comments/{id}/like` - コメントにいいね
  - `DELETE /comments/{id}/like` - コメントのいいね解除

### 通報

- `POST /reports`

### プリサイン URL

- `POST /uploads/tracks/presign`

### プロフィール

- `GET /profiles/{id}`

### 通知トークン

- `POST /me/notifications/token`
- `DELETE /me/notifications/token/{device_id}`

---

## 8. データモデル

### User

- `id`
- `display_name`
- `email`
- `password_hash`
- `created_at`

### Track

- `id`
- `user_id`（作成者）
- `title`
- `tags[]`
- `cover_image_url`
- `audio_url`（HLS プレイリスト）
- `duration`
- `stats`
  - `likes_count`
  - `track_comments_count`
  - `story_comments_count`
  - `plays_count`
  - `has_story`（bool）
- `created_at`

### Story

- `id`
- `track_id`
- `author_user_id`  
  - トラック作成者。DB 制約 or アプリロジックで `Track.user_id` と一致させる。
- `lead`（<= 120 文字）
- `body`（<= 2000 文字、任意）
- `likes_count`
- `created_at`
- `updated_at`
- 制約：**1 トラックにつき 0〜1 行のみ**存在。

### Comment

- `id`
- `target_type`（`track` | `story`）
- `target_id`（`Track.id` または `Story.id`）
- `user_id`
- `body`（<= 500 文字程度）
- `likes_count`（任意）
- `created_at`

### LikeTrack

- `(user_id, track_id)` 複合主キー。

### LikeStory

- `(user_id, story_id)` 複合主キー。

### LikeComment

- `(user_id, comment_id)` 複合主キー。

### Report

- `id`
- `target_type`（`track` / `story` / `comment` / `user`）
- `target_id`
- `reporter_id`
- `reason`
- `status`
- `created_at`

### NotificationToken

- `id`
- `user_id`
- `device_id`
- `push_token`（FCM トークン）
- `platform`（`ios` / `android`）
- `categories[]`
- `created_at`
- `updated_at`

### Notification

- `id`
- `user_id`
- `type`
- `payload`
- `created_at`
- `read_at`（任意）

---

## 9. セキュリティ／審査方針

- UGC ポリシー同意必須。
- 通報・ブロック・削除導線の明示。
- 課金 UI はメタ情報のみ（実課金は Web or 将来のアプリ内課金実装で対応）。
- API 署名／CORS 制御／Rate Limit（Redis）を導入。
- 物語・コメントともにモデレーションポリシーを適用し、違反時は非表示／削除。

---

## 10. KPI（モバイル）

- D1 / D7 リテンション。
- 再生 → 物語展開率。
- 再生 → トラックコメント投稿率。
- 物語閲覧 → 物語コメント投稿率。
- 通知 → 開封 → 再訪コンバージョン。
- 物語付きトラック比率（全トラックのうち、物語が付いている割合）。

---

## 11. テスト戦略（コメント仕様を含む追加点）

- **ユニットテスト（モバイル）**
  - コメント投稿フォーム（物語タブ／コメントタブ）それぞれのバリデーション、エラー表示。
  - タブ／セクション切り替え時に適切なコメント一覧・入力欄が表示されること。
- **ユニットテスト（API）**
  - `target_type` / `target_id` の整合性（存在しないトラック／物語にはコメントできない）。
  - 削除権限（自分のコメントのみ DELETE 可能）。
- **E2E テスト**
  - 「再生 → 物語タブで物語閲覧＋物語コメント → コメントタブでトラックコメント → 通知 → 再訪」までの一連の流れ。

---

## 12. リリース計画（MVP）

- 物語コメントだけでなく**トラックコメントも含めた体験**を初期から入れる前提で設計。
- 再生 → 物語タブ／コメントタブ → トラック／物語コメント → 通知 までのループを最優先。

---

## 13. 制約条件

- 個人開発ペースを尊重しつつ、優先度は  
  **「再生 → 物語タブ／コメントタブ → トラック／物語コメント → 通知」** のループに集中。
- Flutter を前提とした実装に切り替え、React Native / Expo 依存の前提は廃止する。
- バックエンド／インフラの構成は現行の FastAPI + PostgreSQL + Redis + R2 + Railway を継続利用。

---

## 14. 将来拡張

- 投げ銭（Stripe / Web ベース課金 or アプリ内課金）。
- SNS ログイン／パスキー対応。
- 埋め込み検索（音・文ベースのレコメンド）。
- ランキング／コラボ／グループ機能。
- 本格的なオフラインキャッシュ／録音支援機能（Flutter プラグイン選定含む）。
