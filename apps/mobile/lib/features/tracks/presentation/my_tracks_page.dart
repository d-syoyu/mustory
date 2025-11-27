import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../core/network/api_client.dart';
import '../../../features/tracks/data/tracks_repository.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/tracks/presentation/widgets/track_edit_dialog.dart';
import '../../../features/tracks/application/my_tracks_controller.dart';

class MyTracksPage extends HookConsumerWidget {
  const MyTracksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myTracksControllerProvider);
    final controller = ref.read(myTracksControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('マイトラック'),
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
                                    Icons.music_note,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'アップロードした曲がありません',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'プロフィールページから曲をアップロードしましょう',
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
                                  return Stack(
                                    children: [
                                      TrackCard(
                                        track: track,
                                        onTap: () async {
                                          // Play track and navigate to detail
                                          final audioController = ref.read(
                                            audioPlayerControllerProvider
                                                .notifier,
                                          );
                                          await audioController
                                              .playTrack(track);
                                          if (context.mounted) {
                                            context.go('/tracks/${track.id}', extra: track);
                                          }
                                        },
                                        onLike: () {
                                          // Refresh the list after like/unlike
                                          // Note: Ideally we should update local state optimistically
                                          // For now, invalidating provider is simple but might reset scroll
                                          // Better to use controller method if available or just refresh
                                          controller.refresh();
                                        },
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.edit, size: 20),
                                          style: IconButton.styleFrom(
                                            backgroundColor: Colors.black
                                                .withValues(alpha: 0.5),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.all(8),
                                          ),
                                          onPressed: () async {
                                            final result =
                                                await showDialog<dynamic>(
                                              context: context,
                                              builder: (context) =>
                                                  TrackEditDialog(
                                                track: track,
                                                onSave: (title, artistName,
                                                    storyLead,
                                                    storyBody) async {
                                                  final dio =
                                                      ref.read(dioProvider);
                                                  final repository =
                                                      TracksRepository(dio);
                                                  await repository.updateTrack(
                                                    track.id,
                                                    title: title,
                                                    artistName: artistName,
                                                    storyLead: storyLead,
                                                    storyBody: storyBody,
                                                  );
                                                  // Update local list
                                                  controller.updateTrackInList(
                                                    track.id,
                                                    title: title,
                                                    artistName: artistName,
                                                    storyLead: storyLead,
                                                    storyBody: storyBody,
                                                  );
                                                },
                                                onDelete: () async {
                                                  await controller
                                                      .deleteTrack(track.id);
                                                },
                                              ),
                                            );
                                            if (result == true ||
                                                result == 'deleted') {
                                              // Handled in callbacks above or refresh
                                              // controller.refresh();
                                            }
                                          },
                                        ),
                                      ),
                                    ],
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
