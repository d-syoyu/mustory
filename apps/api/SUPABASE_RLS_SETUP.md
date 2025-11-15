# Supabase RLS (Row Level Security) セットアップガイド

## 問題

Supabaseダッシュボードで以下の警告が表示されています：

```
Data is publicly accessible via API as RLS is disabled.
```

これは、データベーステーブルに行レベルセキュリティ (RLS) が設定されていないため、APIを通じて誰でもデータにアクセスできる状態を意味します。

## 解決方法

### ステップ1: Supabaseダッシュボードにログイン

1. https://supabase.com にアクセス
2. プロジェクトを選択
3. 左サイドバーから「SQL Editor」を開く

### ステップ2: RLSポリシーを適用

1. SQL Editorで新しいクエリを作成
2. `supabase_rls_policies.sql` の内容をコピー&ペースト
3. 「Run」ボタンをクリックして実行

### ステップ3: RLSが有効になっているか確認

1. 左サイドバーから「Table Editor」を開く
2. 各テーブル（users, tracks, stories, comments, like_tracks, like_stories, like_comments）を選択
3. 右上の「RLS disabled」警告が消えていることを確認
4. テーブル設定で「Enable RLS」がオンになっていることを確認

## 設定されるポリシー概要

### Users テーブル
- ✅ 全員がユーザープロフィールを閲覧可能（公開情報）
- ✅ 自分のプロフィールのみ更新可能
- ✅ サインアップ時に自分のプロフィールを作成可能

### Tracks テーブル
- ✅ 全員がトラックを閲覧可能（公開コンテンツ）
- ✅ 認証済みユーザーがトラックを作成可能
- ✅ 自分のトラックのみ更新・削除可能

### Stories テーブル
- ✅ 全員がストーリーを閲覧可能（公開コンテンツ）
- ✅ トラックの作成者のみが、そのトラックのストーリーを作成可能
- ✅ 自分のストーリーのみ更新・削除可能

### Comments テーブル
- ✅ 全員が削除されていないコメントを閲覧可能
- ✅ 認証済みユーザーがコメントを作成可能
- ✅ 自分のコメントのみ更新・削除可能

### Like テーブル (Tracks, Stories, Comments)
- ✅ 全員がいいね数を閲覧可能（集計用）
- ✅ 認証済みユーザーがいいねを追加可能
- ✅ 自分のいいねのみ削除可能（unlike）

## セキュリティ上の重要な注意事項

### 1. Supabase Service Role Key の使用

FastAPI バックエンドでは、以下の操作に **Service Role Key** を使用する必要があります：

- `like_count` フィールドの増減
- 管理者操作

**重要**: Service Role Key は RLS をバイパスするため、環境変数で管理し、絶対にクライアントに公開しないでください。

### 2. Anon Key と Authenticated Key

Flutter アプリでは **Anon Key** を使用します：

- RLS ポリシーによって保護される
- クライアントコードに埋め込んでも安全
- ユーザーは自分のデータのみ操作可能

### 3. JWT トークンとユーザー認証

RLS ポリシーでは `auth.uid()` を使用してログインユーザーを識別します：

- Supabase Auth でログインすると JWT トークンが発行される
- RLS ポリシーは JWT から user_id を取得して、アクセス制御を行う

## FastAPI バックエンドでの実装例

### 環境変数の設定

```bash
# .env ファイル
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here  # RLSバイパス用
```

### Supabase クライアントの初期化

```python
from supabase import create_client, Client

# ユーザー操作用（RLS適用）
supabase_client: Client = create_client(
    supabase_url=settings.SUPABASE_URL,
    supabase_key=settings.SUPABASE_ANON_KEY
)

# システム操作用（RLSバイパス）
supabase_admin: Client = create_client(
    supabase_url=settings.SUPABASE_URL,
    supabase_key=settings.SUPABASE_SERVICE_ROLE_KEY
)
```

### Like Count の更新例

```python
# ❌ 間違い: ユーザーが直接 like_count を更新
# RLS ポリシーで拒否される
response = supabase_client.table('tracks').update({
    'like_count': track.like_count + 1
}).eq('id', track_id).execute()

# ✅ 正しい: Service Role Key を使用
response = supabase_admin.table('tracks').update({
    'like_count': track.like_count + 1
}).eq('id', track_id).execute()
```

## トラブルシューティング

### エラー: "new row violates row-level security policy"

**原因**: RLS ポリシーによって操作が拒否されました。

**解決方法**:
1. ユーザーが正しく認証されているか確認
2. JWT トークンが正しく送信されているか確認
3. ポリシー条件（例: `auth.uid()::uuid = user_id`）が満たされているか確認

### エラー: "permission denied for table"

**原因**: テーブルに対する基本的な権限がありません。

**解決方法**:
1. RLS が有効になっているか確認
2. 適切なポリシーが作成されているか確認
3. Service Role Key を使用する必要があるか確認

### 警告が消えない

**解決方法**:
1. ブラウザをリフレッシュ
2. SQL が正常に実行されたか確認（エラーログをチェック）
3. 各テーブルの RLS 設定を手動で確認

## 参考リンク

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase Auth Helpers](https://supabase.com/docs/guides/auth/auth-helpers)
- [PostgreSQL Row Security Policies](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
