# 環境変数の設定方法

Mustory Mobileアプリでは、Supabase URLやAPI URLなどの環境固有の設定を管理するために、環境変数を使用します。

## 方法1: VS Code Launch Configuration（推奨）

### セットアップ

1. `.vscode/launch.json`ファイルが作成されています
2. ファイル内の以下の値を実際の値に置き換えてください:
   - `SUPABASE_URL`: あなたのSupabaseプロジェクトURL
   - `SUPABASE_ANON_KEY`: SupabaseのAnonymous Key
   - `MUSTORY_API_BASE_URL`: バックエンドAPIのURL

### 使用方法

VS Codeで:
1. F5キーを押すか、Run > Start Debugging
2. 設定を選択:
   - **Development**: デフォルト設定
   - **Local Backend**: Androidエミュレータ用（10.0.2.2）

## 方法2: コマンドライン

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=MUSTORY_API_BASE_URL=http://localhost:8000
```

## Supabase設定の取得方法

1. [Supabase Dashboard](https://app.supabase.com) にログイン
2. プロジェクトを選択
3. Settings > API に移動
4. 以下をコピー:
   - **Project URL** → `SUPABASE_URL`
   - **Project API keys > anon public** → `SUPABASE_ANON_KEY`

## ローカル開発の注意点

### Android Emulator
- `localhost`は使用できません
- 代わりに`10.0.2.2`を使用してください
- 例: `http://10.0.2.2:8000`

### iOS Simulator / Real Device
- MacからiOSシミュレータの場合: `http://localhost:8000`
- 実機の場合: PCのローカルIPアドレス（例: `http://192.168.1.100:8000`）

## トラブルシューティング

### "YOUR_SUPABASE_URL" エラー
環境変数が正しく設定されていません。launch.jsonを確認してください。

### API接続エラー
1. バックエンドAPIが起動していることを確認
2. URLが正しいことを確認（Android Emulatorの場合は10.0.2.2）
3. ファイアウォールの設定を確認
