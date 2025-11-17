import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../application/track_detail_controller.dart';
import '../../../core/audio/audio_player_controller.dart';
import 'story_detail_sheet.dart';
import 'comments_detail_sheet.dart';

class TrackDetailPage extends HookConsumerWidget {
  const TrackDetailPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackDetailControllerProvider(trackId));
    final audioState = ref.watch(audioPlayerControllerProvider);
    final selectedTab = useState(0); // 0: 曲, 1: ストーリー

    if (state.isLoading && state.trackDetail == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('読み込み中...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.trackDetail == null) {
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
                  ref.read(trackDetailControllerProvider(trackId).notifier).refresh();
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = state.trackDetail!;
    final track = detail.track;
    final isPlaying = audioState.currentTrack?.id == track.id && audioState.isPlaying;
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final hasStory = track.story != null;

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
                    ? _buildSongTab(context, ref, track, detail, audioState, isPlaying, isCurrentTrack)
                    : _buildStoryTab(context, track, detail),
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
    dynamic track,
    dynamic detail,
    dynamic audioState,
    bool isPlaying,
    bool isCurrentTrack,
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
                        final controller = ref.read(audioPlayerControllerProvider.notifier);
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
                final controller = ref.read(trackDetailControllerProvider(trackId).notifier);
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
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentsDetailSheet(
                    trackId: trackId,
                    trackComments: detail.trackComments,
                  ),
                );
              },
            ),
            Text(
              '${detail.trackComments.length}',
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

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStoryTab(BuildContext context, dynamic track, dynamic detail) {
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

          // ストーリーメタデータとコメントボタン
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
                '${detail.storyComments.length}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => StoryDetailSheet(
                      trackId: trackId,
                      story: story,
                      storyComments: detail.storyComments,
                    ),
                  );
                },
                icon: const Icon(Icons.comment_outlined, size: 20),
                label: const Text('コメント'),
              ),
            ],
          ),

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
}
