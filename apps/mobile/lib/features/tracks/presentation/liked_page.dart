import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/tracks/application/liked_tracks_controller.dart';
import '../../../features/tracks/application/liked_stories_controller.dart';

class LikedPage extends HookConsumerWidget {
  const LikedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('いいね'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: '曲'),
              Tab(text: 'ストーリー'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _LikedTracksTab(),
                  _LikedStoriesTab(),
                ],
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}

class _LikedTracksTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(likedTracksControllerProvider);
    final controller = ref.read(likedTracksControllerProvider.notifier);

    return RefreshIndicator(
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
                            style: Theme.of(context).textTheme.titleMedium,
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
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            !state.isLoading &&
                            state.hasMore) {
                          controller.loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount: state.tracks.length + (state.hasMore ? 1 : 0),
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
    );
  }
}

class _LikedStoriesTab extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(likedStoriesControllerProvider);
    final controller = ref.read(likedStoriesControllerProvider.notifier);

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refresh();
      },
      child: state.isLoading && state.stories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.stories.isEmpty
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
              : state.stories.isEmpty
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
                            'いいねしたストーリーがありません',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'お気に入りのストーリーに❤️をつけましょう',
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
                                scrollInfo.metrics.maxScrollExtent - 200 &&
                            !state.isLoading &&
                            state.hasMore) {
                          controller.loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount:
                            state.stories.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.stories.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final story = state.stories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to track detail with this story
                                context.go('/tracks/${story.trackId}');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            story.lead,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // Unlike story
                                            controller.unlikeStory(story.id);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      story.body,
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${story.likeCount}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
