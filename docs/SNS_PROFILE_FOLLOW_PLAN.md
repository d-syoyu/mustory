# SNS プロフィール/フォロー強化プラン

## 📋 現状まとめ（2025-11-20時点）

### ✅ 実装済み機能

#### バックエンド（FastAPI）
- **DB**: `users`テーブルに以下フィールドが実装済み
  - `username`（一意・インデックス付き）
  - `avatar_url`
  - `bio`（200文字制限）
  - `location`
  - `link_url`
  - `updated_at`
- **マイグレーション**: `202511201200_add_profile_fields_to_users.py`で既存ユーザーに自動バックフィル済み
- **API**:
  - ✅ `GET /me/profile` - 自分のプロフィール取得
  - ✅ `PUT /me/profile` - プロフィール更新（部分更新対応、username重複チェック付き）
  - ✅ `POST /uploads/avatar/presign` - アバターアップロード用プリサインURL生成
  - ✅ `GET /profiles/{user_id}` - 他ユーザーのプロフィール取得
  - ✅ `POST /follows/{user_id}` - フォロー
  - ✅ `DELETE /follows/{user_id}` - アンフォロー
  - ✅ `GET /profiles/{user_id}/followers` - フォロワー一覧（カーソルページング）
  - ✅ `GET /profiles/{user_id}/following` - フォロー中一覧（カーソルページング）
  - ✅ `GET /feed/following` - フォロー中のユーザーのトラック/ストーリーフィード
- **スキーマ**: `UserProfile`と`UserSummary`に全プロフィール項目が含まれる

#### フロントエンド（Flutter）
- **モデル**:
  - ✅ `UserProfile` - username, avatar_url, bio, location, link_url対応
  - ✅ `UserSummary` - フォロワー/フォロー一覧用の軽量モデル
  - ✅ `FeedItem` - フォローフィード用モデル（user情報含む）
- **画面**:
  - ✅ `MyPage` - 自分のプロフィール表示（アバター、username、bio、location、link表示）
  - ✅ `EditProfilePage` - プロフィール編集画面（全フィールド編集可、アバターアップロード機能付き）
  - ✅ `UserProfilePage` - 他ユーザープロフィール表示（フォローボタン付き）
  - ✅ `FollowersPage` - フォロワー一覧（アバター、username表示、無限スクロール）
  - ✅ `FollowingPage` - フォロー中一覧（アバター、username表示、無限スクロール）
  - ✅ `HomePage` - フォロー中フィード表示セクション
- **機能**:
  - ✅ プロフィール編集時のバリデーション
  - ✅ アバター画像のアップロード（ImagePicker + プリサインURL）
  - ✅ フォロー/アンフォロー機能
  - ✅ フォロワー/フォロー中のカーソルページング

### 🔧 改善が必要な箇所

#### 1. **UI/UXの改善点**

##### 1-1. トラックカードからユーザープロフィールへの遷移
**現状**: [track_card.dart](apps/mobile/lib/features/tracks/presentation/widgets/track_card.dart)はアーティスト名を表示するだけで、クリックしてもユーザープロフィールへ遷移できない

**改善案**:
- トラックカードにユーザー情報（アバター + username）を追加
- ユーザー名部分をタップ可能にし、`UserProfilePage`へ遷移
- Trackモデルにuser情報を追加する必要がある

##### 1-2. フォロー中フィードのユーザー情報表示
**現状**: [home_page.dart](apps/mobile/lib/features/home/presentation/home_page.dart)のフォロー中セクションはトラックのみ表示

**改善案**:
- 各トラックカードに投稿者のアバター/usernameを表示
- 「〇〇さんが投稿しました」のような表示を追加
- ユーザー名クリックでプロフィールへ遷移

##### 1-3. UserProfilePageのタブ機能の実装
**現状**: [user_profile_page.dart](apps/mobile/lib/features/profile/presentation/user_profile_page.dart)の「トラック」「物語」「いいね」タブはプレースホルダー

**改善案**:
- ユーザーの投稿トラック一覧を表示
- ユーザーの投稿ストーリー一覧を表示
- いいねしたトラック一覧を表示（プライバシー設定により自分のみ表示）

##### 1-4. フォロワー/フォロー一覧のインラインフォローボタン
**現状**: [followers_page.dart](apps/mobile/lib/features/profile/presentation/followers_page.dart)と[following_page.dart](apps/mobile/lib/features/profile/presentation/following_page.dart)はリスト表示のみ

**改善案**:
- 各ユーザーにフォロー/フォロー中ボタンを追加（trailing部分）
- フォロー状態の管理とリアルタイム更新

##### 1-5. プロフィールの統計情報の充実
**現状**: 基本的な統計は表示されているが、視覚的な訴求力が弱い

**改善案**:
- フォロワー数/フォロー中数をタップ可能にする（既に実装済み）
- トラック数/ストーリー数もタップ可能にして対応するタブへ移動
- より見やすいレイアウトに改善

#### 2. **バックエンドの強化**

##### 2-1. トラック取得APIにユーザー情報を含める
**現状**: トラックAPIレスポンスに`artist_name`のみでユーザー情報が不足

**改善案**:
- TrackスキーマにUserSummary（user_id, username, display_name, avatar_url）を追加
- `/tracks`、`/tracks/{id}`、`/feed/following`などでユーザー情報を返す

##### 2-2. ユーザーのトラック/ストーリー一覧API
**現状**: 特定ユーザーのコンテンツ一覧APIがない

**必要なエンドポイント**:
- `GET /profiles/{user_id}/tracks` - ユーザーの投稿トラック一覧
- `GET /profiles/{user_id}/stories` - ユーザーの投稿ストーリー一覧

##### 2-3. いいね一覧API
**現状**: ユーザーがいいねしたトラック一覧を取得するAPIがない

**必要なエンドポイント**:
- `GET /me/liked-tracks` - 自分がいいねしたトラック一覧
- `GET /profiles/{user_id}/liked-tracks` - 他ユーザーのいいね一覧（プライバシー設定による）

#### 3. **データモデルの調整**

##### 3-1. Trackモデルの拡張
**現状**: [track.dart](apps/mobile/lib/features/tracks/domain/track.dart)にユーザー情報がない

**必要な変更**:
```dart
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artistName,  // 互換性のため残す
    required String userId,
    required String artworkUrl,
    required String hlsUrl,
    UserSummary? user,  // 追加: 投稿者情報
    // ...
  }) = _Track;
}
```

#### 4. **今後の拡張機能（優先度順）**

##### P1（中優先度）
- [ ] フォロー候補API（相互フォロー、人気ユーザーベース）
- [ ] Username検索/オートコンプリート
- [ ] プロフィール共有機能（シェアボタン）
- [ ] 通知機能（新規フォロワー通知）

##### P2（低優先度）
- [ ] プロフィールのピン留めトラック機能
- [ ] ブロック/ミュート機能
- [ ] プロフィールの公開/非公開設定
- [ ] フォロワー数のキャッシュ最適化

## 🎯 実装優先度とタスク

### 最優先（P0）: UI改善とユーザー体験向上

1. **トラックからユーザープロフィールへの導線**
   - [ ] バックエンド: トラックAPIレスポンスにuser情報追加
   - [ ] フロントエンド: Trackモデルにuser追加
   - [ ] フロントエンド: TrackCard/HorizontalTrackCardにユーザー情報表示＋タップ遷移

2. **ユーザーのコンテンツ一覧表示**
   - [ ] バックエンド: `/profiles/{user_id}/tracks` API実装
   - [ ] バックエンド: `/profiles/{user_id}/stories` API実装
   - [ ] フロントエンド: UserProfilePageのタブにトラック/ストーリー一覧実装

3. **フォロー一覧のUX改善**
   - [ ] フロントエンド: フォロワー/フォロー一覧にインラインフォローボタン追加
   - [ ] フロントエンド: フォロー状態の楽観的UI更新

### 次優先（P1）: 機能拡張

4. **いいね機能の充実**
   - [ ] バックエンド: `/me/liked-tracks` API実装
   - [ ] フロントエンド: いいね一覧ページ実装
   - [ ] フロントエンド: UserProfilePageのいいねタブ実装

5. **フォロー中フィードの改善**
   - [ ] フロントエンド: フォロー中セクションに投稿者情報表示
   - [ ] フロントエンド: 「〇〇さんが投稿しました」のようなラベル追加

## 📝 技術メモ

### バリデーションルール
- **username**: 3-30文字、小文字英数字とアンダースコア（`^[a-z0-9_]{3,30}$`）
- **bio**: 最大200文字
- **location**: 最大120文字
- **link_url**: 最大2048文字
- **avatar**: image/jpeg, image/png, image/webp

### ルーティング
- `/profile/edit` - プロフィール編集
- `/users/:userId` - ユーザープロフィール表示
- `/users/:userId/followers` - フォロワー一覧
- `/users/:userId/following` - フォロー中一覧

### 既知の課題
- アバターアップロード後のサムネイル生成が未実装（手動リサイズに依存）
- プロフィールの公開/非公開設定がない（全て公開）
- フォロー/アンフォローのレート制限がない

## 🔗 関連ファイル

### バックエンド
- [models.py](apps/api/app/db/models.py) - DBモデル定義
- [profiles.py](apps/api/app/api/routes/profiles.py) - プロフィール/フォローAPI
- [feed.py](apps/api/app/api/routes/feed.py) - フォローフィードAPI
- [202511201200_add_profile_fields_to_users.py](apps/api/alembic/versions/202511201200_add_profile_fields_to_users.py) - プロフィールフィールド追加マイグレーション

### フロントエンド
- [user_profile.dart](apps/mobile/lib/features/profile/domain/user_profile.dart) - プロフィールモデル
- [my_page.dart](apps/mobile/lib/features/profile/presentation/my_page.dart) - マイページ
- [edit_profile_page.dart](apps/mobile/lib/features/profile/presentation/edit_profile_page.dart) - プロフィール編集
- [user_profile_page.dart](apps/mobile/lib/features/profile/presentation/user_profile_page.dart) - ユーザープロフィール
- [followers_page.dart](apps/mobile/lib/features/profile/presentation/followers_page.dart) - フォロワー一覧
- [following_page.dart](apps/mobile/lib/features/profile/presentation/following_page.dart) - フォロー中一覧
- [track_card.dart](apps/mobile/lib/features/tracks/presentation/widgets/track_card.dart) - トラックカード
- [home_page.dart](apps/mobile/lib/features/home/presentation/home_page.dart) - ホーム画面
