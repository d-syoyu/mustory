import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/tracks/application/liked_tracks_controller.dart';

class LikedTracksPage extends HookConsumerWidget {
  const LikedTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(likedTracksControllerProvider);
    final controller = ref.read(likedTracksControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('いいねした曲'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refresh();
              },
              child: state.isLoading && state.tracks.isEmpty
                  ? const TrackListSkeleton(itemCount: 5)
                  : state.error != null && state.tracks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'エラーが発生しました',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.error!,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => controller.refresh(),
                                child: const Text('再試行'),
                              ),
                            ],
                          ),
                        )
                      : state.tracks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite_border,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'いいねした曲がありません',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'お気に入りの曲に❤️をつけましょう',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            200 &&
                                    !state.isLoading &&
                                    state.hasMore) {
                                  controller.loadMore();
                                }
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: state.tracks.length +
                                    (state.hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.tracks.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  final track = state.tracks[index];
                                  return TrackCard(
                                    track: track,
                                    onTap: () async {
                                      // Play track and navigate to detail
                                      final audioController = ref.read(
                                        audioPlayerControllerProvider.notifier,
                                      );
                                      await audioController.playTrack(track);
                                      if (context.mounted) {
                                        context.go('/tracks/${track.id}', extra: track);
                                      }
                                    },
                                    onLike: () {
                                      // Unlike track
                                      controller.unlikeTrack(track.id);
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
