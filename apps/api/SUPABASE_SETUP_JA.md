# Supabaseセットアップガイド

Mustory APIでSupabase認証とデータベースを設定する手順を説明します。

## 概要

MustoryはSupabaseを使用します：
- **認証**: メール/パスワードログイン、将来的にOAuth・パスキー対応
- **データベース**: PostgreSQL（認証とアプリデータの両方）
- **セキュリティ**: JWT、Row Level Security (RLS)

## セットアップ手順

### 1. Supabaseプロジェクトを作成

1. [supabase.com](https://supabase.com) にアクセスしてログイン
2. 「New Project」をクリック
3. 以下を入力:
   - **プロジェクト名**: `mustory`（任意の名前でOK）
   - **データベースパスワード**: 強力なパスワードを生成（必ず保存してください）
   - **リージョン**: ユーザーに最も近い地域を選択
4. プロジェクトの初期化を待つ（約2分）

### 2. API認証情報を取得

Supabaseダッシュボードで:

1. **Settings** → **API** に移動
2. 以下の値をコピー:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** キー（クライアント側用）
   - **service_role** キー（サーバー側用、**絶対に公開しない**）

### 3. データベース接続文字列を取得

1. **Settings** → **Database** に移動
2. 「Connection string」セクションを探す
3. **「Direct connection」** タブを選択
4. 接続文字列をコピー:
   ```
   postgresql://postgres.xxxxx:[YOUR-PASSWORD]@aws-0-[region].pooler.supabase.com:5432/postgres
   ```
5. `[YOUR-PASSWORD]` を実際のデータベースパスワードに置き換える

### 4. 環境変数を設定

`apps/api/` ディレクトリに `.env` ファイルを作成:

```bash
ENVIRONMENT=local

# Supabase設定
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# データベース（SupabaseのPostgreSQL）
DATABASE_URL=postgresql+psycopg://postgres.xxxxx:[password]@aws-0-[region].pooler.supabase.com:5432/postgres

# Redis
REDIS_URL=redis://localhost:6379/0
```

### 5. Supabaseにマイグレーションを実行

```bash
cd apps/api

# 依存関係をインストール
pip install -e .

# マイグレーションを実行してテーブルを作成
alembic upgrade head
```

これで以下のテーブルが作成されます:
- `public.tracks` - 音楽トラック
- `public.stories` - トラックの物語
- `public.comments` - コメント
- `public.alembic_version` - マイグレーション管理

### 6. 認証をテスト

APIサーバーを起動:
```bash
cd apps/api
uvicorn app.main:app --reload
```

http://localhost:8000/docs にアクセスしてAPIドキュメントを確認

#### ユーザー登録をテスト

**POST `/auth/signup`** を実行:
```json
{
  "email": "test@example.com",
  "password": "password123",
  "display_name": "テストユーザー"
}
```

レスポンス:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "v3-...",
  "token_type": "bearer",
  "user_id": "a1b2c3d4-..."
}
```

#### ログインをテスト

**POST `/auth/login`**:
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

#### 認証済みエンドポイントをテスト

**GET `/auth/me`** にBearerトークンを付けてリクエスト:
```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Flutterアプリとの統合

### 1. Supabase Flutter SDKをインストール

`apps/mobile/pubspec.yaml`:
```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

### 2. Supabaseを初期化

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xxxxx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  );

  runApp(MyApp());
}

final supabase = Supabase.instance.client;
```

### 3. ユーザー登録

```dart
Future<void> signUp(String email, String password, String displayName) async {
  try {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user != null) {
      print('登録成功: ${response.user!.id}');
    }
  } catch (e) {
    print('登録エラー: $e');
  }
}
```

### 4. ログイン

```dart
Future<void> signIn(String email, String password) async {
  try {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session != null) {
      print('ログイン成功');
    }
  } catch (e) {
    print('ログインエラー: $e');
  }
}
```

### 5. APIリクエストにトークンを使用

```dart
import 'package:http/http.dart' as http;

Future<void> fetchTracks() async {
  final session = supabase.auth.currentSession;
  final token = session?.accessToken;

  final response = await http.get(
    Uri.parse('http://localhost:8000/tracks'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print('トラック取得成功');
  }
}
```

### 6. ログアウト

```dart
Future<void> signOut() async {
  await supabase.auth.signOut();
}
```

## データベース構造

### Supabase管理（authスキーマ）

- `auth.users` - ユーザーアカウント
- `auth.sessions` - アクティブセッション
- `auth.identities` - OAuthプロバイダー情報

### アプリケーション（publicスキーマ）

- `public.tracks` - 音楽トラック
  - `user_id` → `auth.users.id` を参照
- `public.stories` - トラックの物語
  - `author_user_id` → `auth.users.id` を参照
- `public.comments` - コメント
  - `author_user_id` → `auth.users.id` を参照

### ユーザーID の関連付け

- ユーザーがSupabase経由で登録すると、`auth.users.id` にUUIDが作成される
- このUUIDを`tracks`, `stories`, `comments` テーブルの `user_id` や `author_user_id` として使用
- 関連付けは自動的 - 追加設定不要！

## Row Level Security (RLS) の設定

**重要**: RLSを有効化しないと、APIキーを持つ誰でもデータベースに直接アクセスできてしまいます。

### RLSポリシーを適用

1. Supabaseダッシュボードで **SQL Editor** を開く
2. `apps/api/supabase_rls_policies.sql` ファイルの内容をコピー
3. SQLエディタに貼り付けて実行

これにより以下のポリシーが適用されます:

**Tracks（トラック）**:
- 誰でも読み取り可能
- 認証済みユーザーは自分のトラックを作成・更新・削除可能

**Stories（物語）**:
- 誰でも読み取り可能
- 認証済みユーザーは自分の物語を作成・更新・削除可能

**Comments（コメント）**:
- 誰でも読み取り可能
- 認証済みユーザーはコメント作成可能
- ユーザーは自分のコメントのみ削除可能

### RLS有効化を確認

Supabaseダッシュボードで **Table Editor** → 各テーブル → **RLS** タブを確認。
"RLS enabled" と表示されていればOKです。

## 高度な機能

### メール確認を有効化

1. **Authentication** → **Settings** に移動
2. 「Enable email confirmations」を有効化
3. メールテンプレートをカスタマイズ

### OAuth（Google、GitHubなど）

1. **Authentication** → **Providers** に移動
2. 使用したいプロバイダーを有効化
3. OAuth認証情報を設定
4. Flutterで使用:
   ```dart
   await supabase.auth.signInWithOAuth(OAuthProvider.google);
   ```

### パスキー対応

Supabase Authで近日対応予定

## セキュリティベストプラクティス

1. ✅ **`service_role` キーは絶対に公開しない**
2. ✅ モバイル/Webクライアントには `anon` キーを使用
3. ✅ Supabaseで Row Level Security (RLS) を有効化
4. ✅ 強力なパスワードポリシーを設定
5. ✅ 本番環境ではメール確認を必須化
6. ✅ 本番環境では必ずHTTPSを使用

## トラブルシューティング

### 「Supabase credentials not configured」エラー

環境変数が正しく設定されているか確認:
```bash
cat apps/api/.env
```

### 認証が失敗する

1. Supabaseダッシュボード → **Authentication** → **Users** を確認
2. メールが確認済みか確認（必要な場合）
3. APIログで詳細なエラーメッセージを確認

### トークンの有効期限切れ

トークンはデフォルトで1時間後に期限切れ。トークン更新を実装:

```dart
supabase.auth.onAuthStateChange.listen((data) {
  final session = data.session;
  // 新しいトークンを保存
});
```

## 本番環境へのデプロイ

### Railway / Renderの場合

環境変数を設定:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_KEY`
- `DATABASE_URL`（Supabaseの接続文字列）

### Dockerの場合

`infra/docker-compose.yml` または `.env` ファイルで設定:

```yaml
services:
  api:
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
      - SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
      - DATABASE_URL=${DATABASE_URL}
```

## リソース

- [Supabase認証ドキュメント](https://supabase.com/docs/guides/auth)
- [Flutter SDK ドキュメント](https://supabase.com/docs/reference/dart/introduction)
- [Supabaseダッシュボード](https://app.supabase.com)
- [Row Level Security (RLS) ガイド](https://supabase.com/docs/guides/auth/row-level-security)
