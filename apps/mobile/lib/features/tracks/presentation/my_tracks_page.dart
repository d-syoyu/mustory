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
import '../../../features/tracks/presentation/widgets/track_edit_dialog.dart';

final myTracksProvider = FutureProvider<List<Track>>((ref) async {
  final dio = ref.watch(dioProvider);
  final repository = TracksRepository(dio);
  return repository.getMyTracks();
});

class MyTracksPage extends HookConsumerWidget {
  const MyTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksAsync = ref.watch(myTracksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイトラック'),
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
                ref.invalidate(myTracksProvider);
              },
              child: tracksAsync.when(
                data: (tracks) {
                  if (tracks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.music_note,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'アップロードした曲がありません',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'プロフィールページから曲をアップロードしましょう',
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
                      return Stack(
                        children: [
                          TrackCard(
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
                              ref.invalidate(myTracksProvider);
                            },
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black.withValues(alpha: 0.5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(8),
                              ),
                              onPressed: () async {
                                final result = await showDialog<dynamic>(
                                  context: context,
                                  builder: (context) => TrackEditDialog(
                                    track: track,
                                    onSave: (title, artistName, storyLead, storyBody) async {
                                      final dio = ref.read(dioProvider);
                                      final repository = TracksRepository(dio);
                                      await repository.updateTrack(
                                        track.id,
                                        title: title,
                                        artistName: artistName,
                                        storyLead: storyLead,
                                        storyBody: storyBody,
                                      );
                                    },
                                    onDelete: () async {
                                      final dio = ref.read(dioProvider);
                                      final repository = TracksRepository(dio);
                                      await repository.deleteTrack(track.id);
                                    },
                                  ),
                                );
                                if (result == true || result == 'deleted') {
                                  ref.invalidate(myTracksProvider);
                                }
                              },
                            ),
                          ),
                        ],
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
                        onPressed: () => ref.invalidate(myTracksProvider),
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
