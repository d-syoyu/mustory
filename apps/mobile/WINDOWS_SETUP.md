# Windows開発環境セットアップ

## シンボリックリンクエラーの解決方法

Flutterプラグインを使用する場合、Windowsでシンボリックリンクサポートが必要です。

### エラーメッセージ
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

### 解決方法

#### オプション1: 開発者モードを有効にする（推奨）

1. **設定を開く**
   - `Win + I` キーを押して設定を開く
   - または、以下のコマンドを実行:
     ```
     start ms-settings:developers
     ```

2. **開発者モードを有効化**
   - 「プライバシーとセキュリティ」→「開発者向け」
   - 「開発者モード」をオンに切り替える
   - 管理者権限が求められる場合があります

3. **VS Codeを再起動**
   - VS Codeを完全に閉じて再起動

4. **再度実行**
   - F5キーでデバッグ実行

#### オプション2: 管理者権限でVS Codeを実行

開発者モードを有効にしたくない場合:

1. VS Codeを右クリック
2. 「管理者として実行」を選択
3. F5でデバッグ実行

**注意**: 毎回管理者権限が必要になるため、オプション1が推奨されます。

#### オプション3: Androidエミュレータで実行

Windows版の代わりにAndroidエミュレータを使用:

1. **Android Studioをインストール**（まだの場合）
2. **AVDを作成**
3. **launch.jsonを更新**（次のセクション参照）

### Androidエミュレータ用のlaunch.json設定

Androidエミュレータで実行する場合、`MUSTORY_API_BASE_URL`を変更する必要があります:

```json
{
  "name": "mustory_mobile (Android Emulator)",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": [
    "--dart-define",
    "SUPABASE_URL=https://ptimmgjijusqbdrmlyou.supabase.co",
    "--dart-define",
    "SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY",
    "--dart-define",
    "MUSTORY_API_BASE_URL=http://10.0.2.2:8000"
  ]
}
```

**重要**: Androidエミュレータから`localhost`にアクセスする場合は`10.0.2.2`を使用します。

### 確認方法

セットアップが完了したら:

```bash
# Flutter doctor でシステム状態を確認
flutter doctor -v

# アプリを実行
flutter run
```

## トラブルシューティング

### 開発者モードを有効にしても解決しない場合

1. **PCを再起動**してください
2. **Gitの設定を確認**:
   ```bash
   git config --global core.symlinks true
   ```
3. **プロジェクトを再クローン**（既存のシンボリックリンクが壊れている場合）

### それでも解決しない場合

一時的な回避策として、プラグインを使用しないシンプルな設定でテスト:

```bash
cd apps/mobile
flutter clean
flutter pub get
flutter run -d windows
```
