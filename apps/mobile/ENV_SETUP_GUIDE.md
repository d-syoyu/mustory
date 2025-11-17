# Flutter アプリの環境変数設定ガイド

## 概要

Flutter アプリを動作させるには、Supabase の認証情報と API のエンドポイントを設定する必要があります。

## 前提条件

- Supabase プロジェクトが作成済み
- バックエンド API が起動している

## 設定手順

### 1. `.env` ファイルの確認

`apps/mobile/.env` ファイルが既に作成されています。このファイルに以下の情報を設定します。

### 2. Supabase 認証情報の取得

1. [Supabase ダッシュボード](https://app.supabase.com) にアクセス
2. プロジェクトを選択
3. 左メニューから **Settings** → **API** を開く
4. 以下の情報をコピー:
   - **Project URL**: `SUPABASE_URL` に設定
   - **anon public key**: `SUPABASE_ANON_KEY` に設定

### 3. `.env` ファイルの編集

`apps/mobile/.env` を以下のように編集します:

```env
# Supabase Configuration
SUPABASE_URL=https://ptimmgjijusqbdrmlyou.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...（実際のキー）

# API Configuration
MUSTORY_API_BASE_URL=http://localhost:8000
```

### 4. Email Confirmation の無効化（開発環境）

開発中は、Supabase の Email Confirmation を無効化することを推奨します。

1. Supabase ダッシュボード → **Authentication** → **Settings** → **Email Auth**
2. **Enable email confirmations** を **OFF** に設定
3. **Save** をクリック

これにより、サインアップ直後にログイン状態になります。

詳細は [SUPABASE_AUTH_SETUP.md](SUPABASE_AUTH_SETUP.md) を参照してください。

### 5. API サーバーの起動

別のターミナルで API サーバーを起動します:

```bash
cd apps/api
uvicorn app.main:app --reload
```

API が http://localhost:8000 で起動していることを確認します。

### 6. Flutter アプリの起動

```bash
cd apps/mobile
flutter pub get
flutter run
```

## トラブルシューティング

### エラー: "Supabase URL is empty"

→ `.env` ファイルが正しく読み込まれていません。
- `.env` ファイルが `apps/mobile/` 直下にあることを確認
- `pubspec.yaml` の `assets:` セクションに `.env` が含まれていることを確認

### エラー: "Network error" または "Connection refused"

→ API サーバーが起動していません。
- `apps/api` で `uvicorn app.main:app --reload` を実行
- http://localhost:8000/docs にアクセスして API が起動しているか確認

### サインアップに失敗する

→ Email Confirmation が有効になっている可能性があります。
- Supabase ダッシュボードで Email Confirmation を無効化
- または、メール送信設定を完了させる

## 次のステップ

1. ログイン画面でアカウント作成をテスト
2. ホーム画面が表示されることを確認
3. トラック一覧が読み込まれることを確認

## 参考ドキュメント

- [Supabase 認証設定](SUPABASE_AUTH_SETUP.md)
- [Windows セットアップ](WINDOWS_SETUP.md)
- [アプリセットアップ](SETUP.md)
