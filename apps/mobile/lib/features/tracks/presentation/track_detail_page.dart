import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../application/track_detail_controller.dart';
import '../domain/track.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../core/auth/auth_controller.dart';
import 'story_detail_sheet.dart';
import 'comments_detail_sheet.dart';
import 'widgets/track_edit_dialog.dart';

class TrackDetailPage extends HookConsumerWidget {
  const TrackDetailPage({
    super.key,
    required this.trackId,
    this.initialTrack,
  });

  final String trackId;
  final Track? initialTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackDetailControllerProvider(trackId));
    final audioState = ref.watch(audioPlayerControllerProvider);
    final selectedTab = useState(0); // 0: 曲, 1: ストーリー
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.maybeWhen(
      authenticated: (userId, _, __, ___) => userId,
      orElse: () => null,
    );
    final isAuthenticated = currentUserId != null;

    // Use initialTrack for optimistic UI if available, otherwise use loaded detail
    final displayTrack = state.trackDetail?.track ?? initialTrack;

    if (displayTrack == null && state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('読み込み中...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (displayTrack == null && state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('エラー')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(state.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(trackDetailControllerProvider(trackId).notifier)
                      .refresh();
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    // If we have displayTrack but no detail yet (optimistic state), we can show basic info
    // If we have detail, we show full info
    final detail = state.trackDetail;
    final track = displayTrack!;
    final isPlaying =
        audioState.currentTrack?.id == track.id && audioState.isPlaying;
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final hasStory = track.story != null;
    final isOwner = isAuthenticated && currentUserId == track.userId;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => context.go('/'),
          ),
          title: const Text(''),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            // 曲/ストーリー切り替えボタン
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      context: context,
                      label: '曲',
                      isSelected: selectedTab.value == 0,
                      onTap: () => selectedTab.value = 0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton(
                      context: context,
                      label: 'ストーリー',
                      isSelected: selectedTab.value == 1,
                      isEnabled: hasStory,
                      onTap: hasStory ? () => selectedTab.value = 1 : null,
                    ),
                  ),
                ],
              ),
            ),

            // コンテンツエリア
            Expanded(
              child: SingleChildScrollView(
                child: selectedTab.value == 0
                    ? _buildSongTab(
                        context,
                        ref,
                        track,
                        detail,
                        audioState,
                        isPlaying,
                        isCurrentTrack,
                        isAuthenticated,
                      )
                    : _buildStoryTab(
                        context,
                        ref,
                        track,
                        detail,
                        isOwner: isOwner,
                        isAuthenticated: isAuthenticated,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String label,
    required bool isSelected,
    bool isEnabled = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isEnabled ? Colors.grey[850] : Colors.grey[900]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (isEnabled ? Colors.grey[800]! : Colors.grey[850]!),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isEnabled ? Colors.white : Colors.grey[600]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongTab(
    BuildContext context,
    WidgetRef ref,
    Track track,
    dynamic detail,
    dynamic audioState,
    bool isPlaying,
    bool isCurrentTrack,
    bool isAuthenticated,
  ) {
    return Column(
      children: [
        const SizedBox(height: 20),

        // 大きなカバーアート
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: track.artworkUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[850],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[850],
                  child: const Icon(Icons.music_note, size: 80),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // トラック情報
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Text(
                track.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                track.artistName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // シークバー
        if (isCurrentTrack) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: audioState.position.inSeconds.toDouble().clamp(
                          0.0,
                          audioState.duration.inSeconds.toDouble() > 0
                              ? audioState.duration.inSeconds.toDouble()
                              : 1.0,
                        ),
                    max: audioState.duration.inSeconds.toDouble() > 0
                        ? audioState.duration.inSeconds.toDouble()
                        : 1.0,
                    onChanged: (value) {
                      ref
                          .read(audioPlayerControllerProvider.notifier)
                          .seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(audioState.position),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        audioState.duration.inSeconds > 0
                            ? '-${_formatDuration(audioState.duration - audioState.position)}'
                            : '0:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: const Slider(
                    value: 0,
                    max: 1,
                    onChanged: null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                      Text(
                        '0:00',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // プレイヤーコントロール
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_previous),
              onPressed: () {
                // TODO: 前の曲へ
              },
            ),
            const SizedBox(width: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: audioState.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : IconButton(
                      iconSize: 32,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final controller =
                            ref.read(audioPlayerControllerProvider.notifier);
                        if (isCurrentTrack) {
                          await controller.togglePlayPause();
                        } else {
                          await controller.playTrack(track);
                        }
                      },
                    ),
            ),
            const SizedBox(width: 24),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.skip_next),
              onPressed: () {
                // TODO: 次の曲へ
              },
            ),
          ],
        ),

        const SizedBox(height: 32),

        // アクションボタン（いいね、コメント、シェア）
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // いいねボタン
            IconButton(
              iconSize: 28,
              icon: Icon(
                track.isLiked ? Icons.favorite : Icons.favorite_border,
                color: track.isLiked ? Colors.red : null,
              ),
              onPressed: () {
                if (!isAuthenticated) {
                  _promptLogin(context);
                  return;
                }
                final controller =
                    ref.read(trackDetailControllerProvider(track.id).notifier);
                if (track.isLiked) {
                  controller.unlikeTrack();
                } else {
                  controller.likeTrack();
                }
              },
            ),
            Text(
              '${track.likeCount}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 24),

            // コメントボタン
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.comment_outlined),
              onPressed: () {
                if (!isAuthenticated) {
                  _promptLogin(context);
                  return;
                }
                // 詳細がロードされるまではコメントシートを開けない、または空で開く
                // ここでは詳細ロード済みの場合のみ開くようにする
                if (detail != null) {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsDetailSheet(
                      trackId: track.id,
                      trackComments: detail.trackComments,
                    ),
                  );
                }
              },
            ),
            Text(
              detail != null ? '${detail.trackComments.length}' : '-',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 24),

            // シェアボタン
            IconButton(
              iconSize: 28,
              icon: const Icon(Icons.share),
              onPressed: () {
                // TODO: シェア機能
              },
            ),
          ],
        ),

        if (!isAuthenticated) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ログインしてコメントやいいねに参加しましょう'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => _promptLogin(context),
                    child: const Text('ログインする'),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStoryTab(
    BuildContext context,
    WidgetRef ref,
    Track track,
    dynamic detail, {
    required bool isOwner,
    required bool isAuthenticated,
  }) {
    if (track.story == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'このトラックにはまだストーリーがありません',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (isOwner) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _openStoryEditor(context, ref, track),
                  icon: const Icon(Icons.menu_book),
                  label: const Text('物語を作成する'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final story = track.story!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ストーリータイトル
          Text(
            story['lead'] as String? ?? '',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // ストーリー本文
          Text(
            story['body'] as String? ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // メタ情報とコメントボタン
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${story['like_count'] ?? 0}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.comment, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                detail != null ? '${detail.storyComments.length}' : '-',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  if (!isAuthenticated) {
                    _promptLogin(context);
                    return;
                  }
                  if (detail != null) {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => StoryDetailSheet(
                        trackId: track.id,
                        story: story,
                        storyComments: detail.storyComments,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.comment_outlined, size: 20),
                label: const Text('コメント'),
              ),
            ],
          ),

          if (isOwner) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _openStoryEditor(context, ref, track),
              icon: const Icon(Icons.edit),
              label: const Text('物語を編集する'),
            ),
          ],

          if (!isAuthenticated) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('ログインして物語へのコメントに参加しましょう'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () => _promptLogin(context),
                      child: const Text('ログインする'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _openStoryEditor(
    BuildContext context,
    WidgetRef ref,
    Track track,
  ) async {
    final controller =
        ref.read(trackDetailControllerProvider(trackId).notifier);

    await showDialog<bool>(
      context: context,
      builder: (context) => TrackEditDialog(
        track: track,
        onSave: (title, artistName, storyLead, storyBody) async {
          await controller.updateTrack(
            title: title,
            artistName: artistName,
            storyLead: storyLead,
            storyBody: storyBody,
          );
        },
      ),
    );
  }

  void _promptLogin(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログインが必要です'),
        content: const Text('コミュニティの参加にはログインしてください。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: const Text('ログインする'),
          ),
        ],
      ),
    );
  }
}
