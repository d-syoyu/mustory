# インディー音楽発見プラットフォーム - モバイルUI設計書

## 1. 概要

本書は、主要音楽ストリーミングサービス（Spotify、Apple Music、YouTube Music）のUI/UXパターンを参考にしながら、「物語」という独自価値を持つ本プラットフォームに最適なモバイルUIを設計するものです。

## 2. 主要サービスの共通UI要素分析

### 2.1 ナビゲーション構造

主要な音楽ストリーミングサービスには以下の共通パターンがあります：

- **ボトムナビゲーションバー**（3-5タブ）
  - ホーム/発見
  - 検索
  - ライブラリ/マイミュージック
  - プロフィール/設定

- **常駐ミニプレイヤー**（ボトムナビの上部に配置）
  - タップで詳細画面へ展開
  - 再生/一時停止の即座操作
  - 現在再生中の曲情報表示

### 2.2 ホーム画面の構成

- 縦スクロール可能なフィード形式
- セクション分けされたコンテンツ
- カルーセル/横スクロール可能なカード
- パーソナライズされたおすすめセクション

### 2.3 プレイヤー画面の特徴

- 大きなカバーアート表示
- 視覚的なシークバー
- 明確なコントロールボタン
- 追加情報へのタブ/セクション

## 3. 本プロジェクト向けUI設計

### 3.1 ボトムナビゲーション構成

```
┌─────────────────────────────────┐
│  🏠 ホーム  📖 物語  🔍 検索  👤 マイページ │
└─────────────────────────────────┘
```

**4タブ構成：**

1. **ホーム**
   - 新着・おすすめトラック一覧
   - パーソナライズされた「あなたへのおすすめ」
   - 注目のトラック

2. **物語**
   - Story Feed（物語フィード）
   - 最新の物語更新を横断表示
   - 物語を中心としたコンテンツ発見

3. **検索**
   - タグ・タイトル・アーティスト検索
   - 検索履歴
   - トレンドタグ

4. **マイページ**
   - プロフィール
   - 自分の投稿トラック一覧
   - いいね履歴
   - 設定

### 3.2 ホーム画面の詳細設計

```
┌───────────────────────────────┐
│ ◀ あなたへのおすすめ ▶          │
│ ┌────┐ ┌────┐ ┌────┐ ┌────┐ │ ← 横スクロールカルーセル
│ │    │ │    │ │    │ │    │ │
│ │カバ│ │カバ│ │カバ│ │カバ│ │
│ │    │ │    │ │    │ │    │ │
│ └────┘ └────┘ └────┘ └────┘ │
│   曲名     曲名     曲名     曲名   │
├───────────────────────────────┤
│ 🔥 今日の注目                  │
│ ┌─────────────────────────┐ │
│ │ [カバー] タイトル          │ │
│ │ 120x120 アーティスト名     │ │ ← 縦スクロールリスト
│ │         👁️ 1.2k 💬 45 ❤️ 230 │ │
│ │         📖 物語あり        │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ [カバー] タイトル2         │ │
│ │         アーティスト名2    │ │
│ │         👁️ 856 💬 23 ❤️ 145  │ │
│ └─────────────────────────┘ │
├───────────────────────────────┤
│ 🆕 新着トラック                │
│ ┌─────────────────────────┐ │
│ │ [カバー] ...               │ │
│ └─────────────────────────┘ │
└───────────────────────────────┘
```

**セクション構成例：**

- **あなたへのおすすめ**（最上部、横カルーセル）
  - おすすめアルゴリズムによるパーソナライズ
  - 再生履歴・いいね履歴から算出
  
- **今日の注目**
  - 再生数・いいね数上位のトラック
  - 24時間以内のトレンド

- **新着トラック**
  - 時系列順の新規投稿
  
- **物語が更新されたトラック**
  - 最近物語が追加・更新されたトラック
  
- **フォロー中のアーティスト**（将来拡張）
  - フォロー機能実装時に追加

**カード表示の統計情報：**

- 👁️ 再生数
- 💬 コメント数（合計 or トラック+物語の内訳）
- ❤️ いいね数
- 📖 物語有無のアイコン

### 3.3 トラック詳細画面の設計

主要サービスを参考に、**タブUI**を採用します。

```
┌───────────────────────────────┐
│          ⌄ 下にスワイプで最小化 │
├───────────────────────────────┤
│                               │
│                               │
│      [カバーアート大]          │
│         320x320               │
│                               │
│                               │
├───────────────────────────────┤
│      トラックタイトル          │
│      アーティスト名            │
│                               │
│ ═══════════════════════════   │ ← シークバー
│  0:45                  -1:23  │
│                               │
│   ⏮    ⏯    ⏭    🔀   🔁    │ ← プレイヤーコントロール
│                               │
│   ❤️ いいね   📤 シェア        │
├───────────────────────────────┤
│   [📖 物語]   [💬 コメント]    │ ← タブバー（スイッチ可能）
├───────────────────────────────┤
│                               │
│   (選択中のタブのコンテンツ)  │
│                               │
│                               │
│                               │
└───────────────────────────────┘
```

#### 物語タブの詳細

```
┌───────────────────────────────┐
│ 📖 この曲について              │
│                               │
│ ┌─────────────────────────┐ │
│ │ 物語のリード（120字以内） │ │
│ │ この曲は深夜の静寂の中で  │ │
│ │ 生まれました。雨音だけが  │ │
│ │ 聞こえる部屋で...         │ │
│ │                           │ │
│ │ ...続きを読む ▼           │ │ ← タップで全文展開
│ └─────────────────────────┘ │
│                               │
│ ❤️ 45   💬 12                 │
│                               │
├─ 物語へのコメント ─────────────┤
│                               │
│ 💬 コメントする...             │ ← タップでキーボード表示
│                               │
│ 👤 ユーザーA       ❤️ 3       │
│    感動しました！素敵な背景    │
│    ですね。                   │
│    2時間前                    │
│                               │
│ 👤 ユーザーB       ❤️ 1       │
│    背景を知ることで曲の聴こえ  │
│    方が変わりました。          │
│    5時間前                    │
│                               │
│ 👤 ユーザーC                  │
│    雨の日にまた聴きたい       │
│    8時間前                    │
└───────────────────────────────┘
```

**物語タブの要素：**

- 物語本文（リード + 全文展開）
- 物語へのいいね・コメント数
- 物語へのコメント投稿欄（最上部固定）
- 物語へのコメント一覧
- トラック作成者には「物語を作成/編集」ボタン表示

#### コメントタブの詳細

```
┌───────────────────────────────┐
│ 💬 この曲へのコメント          │
│                               │
│ 💬 コメントする...             │ ← タップでキーボード表示
│                               │
│ 👤 ユーザーC       ❤️ 8       │
│    めっちゃ良い！リピート確定！│
│    1時間前                    │
│                               │
│ 👤 ユーザーD       ❤️ 5       │
│    またリピートします。        │
│    作業用BGMに最高です。       │
│    3時間前                    │
│                               │
│ 👤 ユーザーE       ❤️ 2       │
│    サビのメロディが耳に残る    │
│    6時間前                    │
│                               │
│ 👤 ユーザーF                  │
│    シェアしました！           │
│    10時間前                   │
└───────────────────────────────┘
```

**コメントタブの要素：**

- トラックへのコメント投稿欄（最上部固定）
- トラックへのコメント一覧
- 各コメントへのいいねボタン

### 3.4 物語フィード画面

```
┌───────────────────────────────┐
│        📖 物語フィード         │
├───────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ [小カバー] トラックタイトル │ │
│ │   80x80    by アーティスト  │ │
│ │                           │ │
│ │ 物語のリード（120字以内）  │ │
│ │ 深夜の静寂の中で生まれた  │ │
│ │ この曲は...               │ │
│ │                           │ │
│ │ ...続きを読む             │ │
│ │                           │ │
│ │ ❤️ 45  💬 12  2時間前      │ │
│ └─────────────────────────┘ │
│                               │
│ ┌─────────────────────────┐ │
│ │ [小カバー] トラックタイトル2│ │
│ │            by アーティスト2 │ │
│ │                           │ │
│ │ 物語のリード...           │ │
│ │                           │ │
│ │ ...続きを読む             │ │
│ │                           │ │
│ │ ❤️ 23  💬 7  5時間前       │ │
│ └─────────────────────────┘ │
│                               │
│ ┌─────────────────────────┐ │
│ │ [小カバー] ...            │ │
└───────────────────────────────┘
```

**物語フィードの特徴：**

- トラック横断で最新の物語を表示
- カードタップでトラック詳細の「物語タブ」へ遷移
- アーティストの創作背景を追いやすい設計

### 3.5 ミニプレイヤー（常駐）

```
┌───────────────────────────────┐
│ ▓▓▓▓▓░░░░░░░░░░░░░░░░░░      │ ← 再生進捗バー（薄く表示）
├───────────────────────────────┤
│ [小カバー] トラックタイトル  ⏯ │
│   60x60    アーティスト名    ⋮ │ ← ⋮はメニュー（お気に入り追加等）
└───────────────────────────────┘
     ↑
  タップで詳細画面へ展開
```

**ミニプレイヤーの機能：**

- タップで詳細画面へ展開
- 再生/一時停止ボタン
- 進捗バーの視覚的表示
- メニューボタン（お気に入り追加、プレイリスト追加等）

### 3.6 検索画面

```
┌───────────────────────────────┐
│ 🔍 検索                        │
│ ┌─────────────────────────┐ │
│ │ 🔍 曲名、アーティスト、タグ │ │ ← 検索バー
│ └─────────────────────────┘ │
├───────────────────────────────┤
│ 最近の検索                     │
│ • ピアノ                       │
│ • アコースティック             │
│ • ユーザーA                    │
├───────────────────────────────┤
│ トレンドタグ                   │
│ #LoFi  #アンビエント  #弾き語り│
│ #インスト  #Jazz  #エレクトロニカ│
└───────────────────────────────┘
```

**検索結果画面：**

```
┌───────────────────────────────┐
│ 🔍 "ピアノ"                    │
├───────────────────────────────┤
│ [トラック] [物語] [アーティスト]│ ← タブで結果切り替え
├───────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ [カバー] トラックタイトル  │ │
│ │         アーティスト名     │ │
│ │         #ピアノ #弾き語り  │ │
│ │         👁️ 1.2k 💬 45 ❤️ 230 │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ [カバー] ...              │ │
└───────────────────────────────┘
```

### 3.7 マイページ画面

```
┌───────────────────────────────┐
│ 👤 プロフィール                │
│                               │
│      [プロフィール画像]        │
│      ユーザー名                │
│      @username                │
│                               │
│ ┌─────┐ ┌─────┐ ┌─────┐     │
│ │ 15  │ │ 234 │ │ 89  │     │
│ │トラック│ │いいね│ │フォロワー│ │
│ └─────┘ └─────┘ └─────┘     │
├───────────────────────────────┤
│ [投稿トラック] [いいね] [設定] │ ← タブ
├───────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ [カバー] 自分のトラック1   │ │
│ │         👁️ 856 💬 23 ❤️ 145  │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ [カバー] 自分のトラック2   │ │
│ │         👁️ 432 💬 12 ❤️ 78   │ │
│ └─────────────────────────┘ │
└───────────────────────────────┘
```

### 3.8 投稿画面（Upload Track）

```
┌───────────────────────────────┐
│ ← トラックをアップロード        │
├───────────────────────────────┤
│                               │
│     [カバー画像選択]          │
│     タップして画像を選択       │
│                               │
├───────────────────────────────┤
│ 音源ファイル                   │
│ ┌─────────────────────────┐ │
│ │ 📁 ファイルを選択          │ │
│ └─────────────────────────┘ │
│ または                        │
│ ┌─────────────────────────┐ │
│ │ 🎵 my_track.mp3 (5.2MB)   │ │ ← 選択後
│ │    ×                      │ │
│ └─────────────────────────┘ │
├───────────────────────────────┤
│ タイトル                       │
│ ┌─────────────────────────┐ │
│ │                           │ │
│ └─────────────────────────┘ │
│                               │
│ タグ（カンマ区切り）           │
│ ┌─────────────────────────┐ │
│ │ ピアノ, アンビエント       │ │
│ └─────────────────────────┘ │
│                               │
│ 物語を追加（任意）             │
│ ┌─────────────────────────┐ │
│ │ リード（120字以内）        │ │
│ │                           │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 本文（2000字以内）         │ │
│ │                           │ │
│ │                           │ │
│ └─────────────────────────┘ │
│                               │
│      [アップロード]            │
└───────────────────────────────┘
```

## 4. Flutter実装推奨パターン

### 4.1 アプリ全体の構造

```dart
// main.dart - アプリのエントリーポイント
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark, // ダークテーマ推奨
      ),
    );
  }
}

// メインスキャフォールド
class MainScaffold extends ConsumerStatefulWidget {
  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            HomeScreen(),
            StoryFeedScreen(),
            SearchScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayer(), // 常駐ミニプレイヤー
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'ホーム',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book),
                label: '物語',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '検索',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'マイページ',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 4.2 ホーム画面の実装

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracks = ref.watch(tracksProvider);
    
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          title: Text('ホーム'),
        ),
        
        // あなたへのおすすめセクション（横スクロール）
        SliverToBoxAdapter(
          child: RecommendedSection(),
        ),
        
        // 今日の注目セクション
        SliverToBoxAdapter(
          child: SectionHeader(title: '🔥 今日の注目'),
        ),
        
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => TrackCard(track: tracks[index]),
            childCount: tracks.length,
          ),
        ),
      ],
    );
  }
}

// おすすめセクション（横スクロールカルーセル）
class RecommendedSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommended = ref.watch(recommendedTracksProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'あなたへのおすすめ'),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommended.length,
            itemBuilder: (context, index) {
              return RecommendedCard(track: recommended[index]);
            },
          ),
        ),
      ],
    );
  }
}

// トラックカード（縦リスト用）
class TrackCard extends StatelessWidget {
  final Track track;
  
  const TrackCard({required this.track});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/tracks/${track.id}'),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // カバー画像
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                track.coverImageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            
            // トラック情報
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    track.artistName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  
                  // 統計情報
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${track.playsCount}', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 12),
                      Icon(Icons.comment, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${track.commentsCount}', style: TextStyle(fontSize: 12)),
                      SizedBox(width: 12),
                      Icon(Icons.favorite, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('${track.likesCount}', style: TextStyle(fontSize: 12)),
                      if (track.hasStory) ...[
                        SizedBox(width: 12),
                        Icon(Icons.book, size: 14, color: Colors.deepPurple),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4.3 トラック詳細画面の実装（タブUI）

```dart
class TrackDetailScreen extends ConsumerStatefulWidget {
  final String trackId;
  
  const TrackDetailScreen({required this.trackId});
  
  @override
  ConsumerState<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends ConsumerState<TrackDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final track = ref.watch(trackDetailProvider(widget.trackId));
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // カバーアート＋プレイヤーコントロール
            SliverAppBar(
              expandedHeight: 500,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    SizedBox(height: 60),
                    
                    // カバーアート
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          track.coverImageUrl,
                          width: 320,
                          height: 320,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // トラック情報
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            track.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            track.artistName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 24),
                          
                          // シークバー
                          PlayerSeekBar(),
                          
                          SizedBox(height: 24),
                          
                          // プレイヤーコントロール
                          PlayerControls(),
                          
                          SizedBox(height: 16),
                          
                          // アクションボタン
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LikeButton(trackId: track.id),
                              SizedBox(width: 24),
                              ShareButton(trackId: track.id),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // タブバー
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.book),
                      text: '物語',
                    ),
                    Tab(
                      icon: Icon(Icons.comment),
                      text: 'コメント',
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        
        body: TabBarView(
          controller: _tabController,
          children: [
            StoryTabContent(trackId: widget.trackId),
            CommentsTabContent(trackId: widget.trackId),
          ],
        ),
      ),
    );
  }
}

// タブバーを固定するためのDelegate
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _StickyTabBarDelegate(this.tabBar);
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }
  
  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}

// 物語タブのコンテンツ
class StoryTabContent extends ConsumerWidget {
  final String trackId;
  
  const StoryTabContent({required this.trackId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final story = ref.watch(storyProvider(trackId));
    
    return story.when(
      data: (story) {
        if (story == null) {
          return Center(
            child: Text('この曲にはまだ物語がありません'),
          );
        }
        
        return ListView(
          padding: EdgeInsets.all(16),
          children: [
            // 物語本文
            StoryContent(story: story),
            
            SizedBox(height: 24),
            Divider(),
            SizedBox(height: 16),
            
            // 物語へのコメントセクション
            Text(
              '物語へのコメント',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // コメント投稿欄
            CommentInput(
              targetType: 'story',
              targetId: story.id,
            ),
            
            SizedBox(height: 24),
            
            // コメント一覧
            StoryCommentslist(storyId: story.id),
          ],
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('エラーが発生しました')),
    );
  }
}

// コメントタブのコンテンツ
class CommentsTabContent extends ConsumerWidget {
  final String trackId;
  
  const CommentsTabContent({required this.trackId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'この曲へのコメント',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        
        // コメント投稿欄
        CommentInput(
          targetType: 'track',
          targetId: trackId,
        ),
        
        SizedBox(height: 24),
        
        // コメント一覧
        TrackCommentsList(trackId: trackId),
      ],
    );
  }
}
```

### 4.4 ミニプレイヤーの実装

```dart
class MiniPlayer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTrack = ref.watch(currentTrackProvider);
    final playbackState = ref.watch(playbackStateProvider);
    
    if (currentTrack == null) {
      return SizedBox.shrink();
    }
    
    return GestureDetector(
      onTap: () => context.push('/tracks/${currentTrack.id}'),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // 進捗バー
            LinearProgressIndicator(
              value: playbackState.position / playbackState.duration,
              minHeight: 2,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
            ),
            
            // プレイヤー本体
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // カバー画像
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        currentTrack.coverImageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // トラック情報
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentTrack.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            currentTrack.artistName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // 再生/一時停止ボタン
                    IconButton(
                      icon: Icon(
                        playbackState.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      onPressed: () {
                        ref.read(audioPlayerProvider).togglePlayPause();
                      },
                    ),
                    
                    // メニューボタン
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {
                        // メニュー表示
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 5. UX最適化ポイント

### 5.1 主要サービスに倣うべき点

#### スワイプジェスチャー

- **左右スワイプ**：トラック詳細画面で曲送り/戻し
- **下スワイプ**：トラック詳細画面をミニプレイヤーへ最小化
- **上スワイプ**：ミニプレイヤーからトラック詳細画面へ展開

実装例：
```dart
GestureDetector(
  onVerticalDragEnd: (details) {
    if (details.primaryVelocity! > 0) {
      // 下スワイプ: 最小化
      Navigator.pop(context);
    }
  },
  child: TrackDetailContent(),
)
```

#### 視覚的フィードバック

1. **いいねボタンのアニメーション**
   ```dart
   AnimatedScale(
     scale: isLiked ? 1.2 : 1.0,
     duration: Duration(milliseconds: 200),
     child: Icon(
       isLiked ? Icons.favorite : Icons.favorite_border,
       color: isLiked ? Colors.red : Colors.grey,
     ),
   )
   ```

2. **再生中の波形/進捗の視覚化**
   - Lottie アニメーション
   - カスタムペイントでの波形描画

3. **スケルトンローディング**
   ```dart
   Shimmer.fromColors(
     baseColor: Colors.grey[800]!,
     highlightColor: Colors.grey[700]!,
     child: Container(
       width: 80,
       height: 80,
       color: Colors.white,
     ),
   )
   ```

#### スムーズな遷移

1. **Hero アニメーション**（カバーアート）
   ```dart
   Hero(
     tag: 'cover-${track.id}',
     child: Image.network(track.coverImageUrl),
   )
   ```

2. **ページ遷移**
   - 300ms 以内の遷移時間
   - go_router での `pageBuilder` カスタマイズ

#### 親指操作領域

- 重要なボタンは画面下部 1/3 に配置
- タブバーのタップ領域：最低 44x44pt
- ボトムナビゲーションバーのアイコンサイズ：24x24pt
- ボタン間の余白：最低 8pt

### 5.2 本プロジェクト独自の工夫

#### 物語の視認性

1. **トラックカードでの表示**
   ```dart
   if (track.hasStory)
     Container(
       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
       decoration: BoxDecoration(
         color: Colors.deepPurple.withOpacity(0.2),
         borderRadius: BorderRadius.circular(4),
       ),
       child: Row(
         mainAxisSize: MainAxisSize.min,
         children: [
           Icon(Icons.book, size: 14, color: Colors.deepPurple),
           SizedBox(width: 4),
           Text('物語あり', style: TextStyle(fontSize: 11)),
         ],
       ),
     )
   ```

2. **物語フィードの専用タブ**
   - ボトムナビゲーションの2番目
   - アイコンは📖（本）で視覚的に明示

#### コメント導線の明確化

1. **タブの最上部に入力欄を固定**
   ```dart
   ListView(
     children: [
       // 最上部にコメント入力欄
       CommentInput(),
       SizedBox(height: 16),
       
       // その下にコメント一覧
       CommentsList(),
     ],
   )
   ```

2. **プレースホルダーテキストの工夫**
   - 物語タブ：「物語への感想を書く...」
   - コメントタブ：「この曲への感想を書く...」

#### 統計表示の工夫

```dart
Row(
  children: [
    _StatItem(icon: Icons.remove_red_eye, value: track.playsCount),
    SizedBox(width: 12),
    _StatItem(icon: Icons.comment, value: track.commentsCount),
    SizedBox(width: 12),
    _StatItem(icon: Icons.favorite, value: track.likesCount),
    if (track.hasStory) ...[
      SizedBox(width: 12),
      Icon(Icons.book, size: 14, color: Colors.deepPurple),
    ],
  ],
)

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        SizedBox(width: 4),
        Text(
          _formatCount(value),
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
```

## 6. パフォーマンス最適化

### 6.1 画像読み込み最適化

```dart
// cached_network_image を使用
CachedNetworkImage(
  imageUrl: track.coverImageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[800]!,
    highlightColor: Colors.grey[700]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fadeInDuration: Duration(milliseconds: 300),
  memCacheWidth: 400, // メモリキャッシュのサイズ制限
)
```

### 6.2 リスト表示の最適化

```dart
// ListView.builder を使用（遅延レンダリング）
ListView.builder(
  itemCount: tracks.length,
  itemBuilder: (context, index) {
    return TrackCard(track: tracks[index]);
  },
  cacheExtent: 500, // 画面外のアイテムをキャッシュ
)
```

### 6.3 オーディオ再生の最適化

```dart
// just_audio + audio_service
final player = AudioPlayer();

// HLS対応
await player.setUrl('https://example.com/track.m3u8');

// バックグラウンド再生
AudioService.init(
  builder: () => AudioPlayerHandler(),
  config: AudioServiceConfig(
    androidNotificationChannelId: 'com.example.app.audio',
    androidNotificationChannelName: 'Music playback',
  ),
);
```

## 7. アクセシビリティ対応

### 7.1 セマンティクスの追加

```dart
Semantics(
  label: 'いいねボタン。現在${isLiked ? "いいね済み" : "未いいね"}',
  button: true,
  child: IconButton(
    icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
    onPressed: onPressed,
  ),
)
```

### 7.2 コントラストの確保

```dart
// ダークテーマでのコントラスト比 4.5:1 以上
TextStyle(
  color: Colors.white, // 背景が暗い場合
  fontSize: 16,
)
```

### 7.3 フォントサイズの可変対応

```dart
// MediaQuery.textScaleFactorを考慮
Text(
  track.title,
  style: TextStyle(
    fontSize: 16, // システムのテキストサイズ設定に応じて自動スケール
  ),
)
```

## 8. 推奨UI構成まとめ

### ✅ 採用すべき構成

1. **ボトムナビゲーション4タブ**
   - ホーム / 物語 / 検索 / マイページ

2. **常駐ミニプレイヤー**
   - ボトムナビの上部に配置
   - タップで詳細画面へ展開

3. **トラック詳細のタブUI**
   - 物語タブ / コメントタブ
   - スワイプで切り替え可能

4. **ホーム画面のセクション構成**
   - 横スクロールカルーセル（おすすめ）
   - 縦スクロールリスト（注目・新着）

5. **カードベースのリスト表示**
   - カバー画像 + タイトル + 統計情報
   - 一目で情報を把握できるレイアウト

### ✅ UXのポイント

- **スワイプジェスチャー**で直感的な操作
- **Hero アニメーション**でスムーズな画面遷移
- **スケルトンローディング**で体感速度向上
- **親指操作領域**を意識したボタン配置
- **視覚的フィードバック**でアクションの結果を明示

### ✅ 本プロジェクト独自の価値

- 物語フィードの**専用タブ**で物語の発見を促進
- トラック詳細での**物語タブ/コメントタブ**の明確な分離
- 物語の有無を**アイコンで視覚化**
- コメント入力欄を**最上部に固定**して投稿しやすく

## 9. 次のステップ

このUI設計をもとに、以下のステップで実装を進めることを推奨します：

1. **プロトタイプ作成**
   - Figma / Adobe XD でのモックアップ作成
   - 主要画面のデザイン確定

2. **コンポーネント実装**
   - 再利用可能なウィジェットの作成
   - TrackCard / MiniPlayer / CommentInput など

3. **画面実装**
   - ホーム画面 → トラック詳細画面 → 物語フィード画面の順

4. **統合**
   - 状態管理（Riverpod）の統合
   - API連携
   - オーディオプレイヤーの統合

5. **テスト**
   - ユニットテスト
   - ウィジェットテスト
   - E2Eテスト

6. **改善**
   - ユーザーフィードバックの収集
   - パフォーマンスチューニング
   - UX改善

---

## 付録：参考リソース

### Flutter パッケージ

- **状態管理**: riverpod, hooks_riverpod
- **ルーティング**: go_router
- **オーディオ**: just_audio, audio_service
- **画像**: cached_network_image
- **UI**: flutter_hooks, animations
- **ローディング**: shimmer
- **アニメーション**: lottie

### デザインリファレンス

- [Material Design 3](https://m3.material.io/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Spotify Design](https://spotify.design/)

### 実装参考

- [Flutter Samples](https://flutter.github.io/samples/)
- [Pub.dev](https://pub.dev/) - Flutterパッケージリポジトリ
