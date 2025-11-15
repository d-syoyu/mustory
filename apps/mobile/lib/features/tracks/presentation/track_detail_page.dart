import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../application/tracks_controller.dart';
import '../domain/track.dart';

final trackDetailProvider = FutureProvider.family<Track, String>((ref, trackId) async {
  final repository = ref.watch(tracksRepositoryProvider);
  return repository.getTrackById(trackId);
});

class TrackDetailPage extends ConsumerWidget {
  const TrackDetailPage({super.key, required this.trackId});

  final String trackId;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackDetailProvider(trackId));
    final audioState = ref.watch(audioPlayerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('トラック詳細'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
            tooltip: 'シェア',
          ),
        ],
      ),
      body: trackAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  ref.invalidate(trackDetailProvider(trackId));
                },
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
        data: (track) {
          final isCurrentTrack = audioState.currentTrack?.id == track.id;
          final isPlaying = isCurrentTrack && audioState.isPlaying;
          final isLoading = isCurrentTrack && audioState.isLoading;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(trackDetailProvider(trackId));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          track.artworkUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.music_note,
                                size: 96,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title and Artist
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
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Audio Controls
                    if (isCurrentTrack) ...[
                      // Progress Slider
                      Column(
                        children: [
                          Slider(
                            value: audioState.duration.inMilliseconds > 0
                                ? audioState.position.inMilliseconds.toDouble()
                                : 0.0,
                            max: audioState.duration.inMilliseconds > 0
                                ? audioState.duration.inMilliseconds.toDouble()
                                : 1.0,
                            onChanged: (value) {
                              final controller = ref.read(
                                audioPlayerControllerProvider.notifier,
                              );
                              controller.seek(Duration(milliseconds: value.toInt()));
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(audioState.position),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  _formatDuration(audioState.duration),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Play/Pause Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final controller = ref.read(
                                    audioPlayerControllerProvider.notifier,
                                  );
                                  if (isCurrentTrack) {
                                    await controller.togglePlayPause();
                                  } else {
                                    await controller.playTrack(track);
                                  }
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isPlaying ? '一時停止' : '再生'),
                        ),
                        const SizedBox(width: 16),
                        // Like Button
                        IconButton.outlined(
                          onPressed: () {
                            // TODO: Implement like toggle
                          },
                          icon: Icon(
                            track.isLiked ? Icons.favorite : Icons.favorite_border,
                            color: track.isLiked ? Colors.red : null,
                          ),
                        ),
                        Text(
                          '${track.likeCount}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Story Section
                    if (track.hasStory) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '物語',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          track.story?['content'] ?? '',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'このトラックにはまだ物語がありません',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
