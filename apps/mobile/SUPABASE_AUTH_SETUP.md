# Supabase認証の設定手順

## 問題: サインアップに失敗する

Supabaseのデフォルト設定では、Email Confirmationが有効になっています。
開発中は確認メールの送信設定が未完了の場合が多く、サインアップが完了できません。

## 解決方法1: Email Confirmationを無効化（開発用・推奨）

1. [Supabaseダッシュボード](https://app.supabase.com) にアクセス
2. プロジェクト `ptimmgjijusqbdrmlyou` を選択
3. 左メニューから **Authentication** → **Settings** → **Email Auth** を選択
4. **Enable email confirmations** のトグルを **OFF** に設定
5. **Save** をクリック

これにより、サインアップ直後にログイン状態になります。

## 解決方法2: メール送信の設定（本番用）

1. Supabaseダッシュボード → **Project Settings** → **Auth**
2. **Email Templates** セクションでConfirm signupテンプレートを確認
3. **SMTP Settings** または **SendGrid/Resend** などのメールプロバイダーを設定

## 確認方法

設定後、アプリでサインアップを試みて:
- Email Confirmation OFFの場合: すぐにホーム画面に遷移
- Email Confirmation ONの場合: メールに確認リンクが届く

## 現在の設定確認

Supabaseダッシュボードで確認:
- URL: https://ptimmgjijusqbdrmlyou.supabase.co
- Authentication → Settings → Email Auth
- 「Enable email confirmations」の状態をチェック
