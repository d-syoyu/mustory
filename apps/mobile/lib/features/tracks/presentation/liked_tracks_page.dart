import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../core/network/api_client.dart';
import '../../../features/tracks/data/tracks_repository.dart';
import '../../../features/tracks/domain/track.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';

final likedTracksProvider = FutureProvider<List<Track>>((ref) async {
  final dio = ref.watch(dioProvider);
  final repository = TracksRepository(dio);
  return repository.getLikedTracks();
});

class LikedTracksPage extends HookConsumerWidget {
  const LikedTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(likedTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('いいねした曲'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(likedTracksProvider);
              },
              child: tracksAsync.when(
                data: (tracks) {
                  if (tracks.isEmpty) {
                    return Center(
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
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'お気に入りの曲に❤️をつけましょう',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: tracks.length,
                    itemBuilder: (context, index) {
                      final track = tracks[index];
                      return TrackCard(
                        track: track,
                        onTap: () async {
                          // Play track and navigate to detail
                          final audioController = ref.read(
                            audioPlayerControllerProvider.notifier,
                          );
                          await audioController.playTrack(track);
                          if (context.mounted) {
                            context.go('/tracks/${track.id}');
                          }
                        },
                        onLike: () {
                          // Refresh the list after like/unlike
                          ref.invalidate(likedTracksProvider);
                        },
                      );
                    },
                  );
                },
                loading: () => const TrackListSkeleton(itemCount: 5),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
                      ElevatedButton(
                        onPressed: () => ref.invalidate(likedTracksProvider),
                        child: const Text('再試行'),
                      ),
                    ],
                  ),
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
