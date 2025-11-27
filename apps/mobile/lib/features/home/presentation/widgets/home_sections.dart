import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../profile/application/profile_controller.dart';
import '../../../tracks/application/recommended_tracks_provider.dart';
import '../../../tracks/application/tracks_controller.dart';
import '../../../tracks/presentation/widgets/horizontal_track_card.dart';
import '../../../tracks/presentation/widgets/compact_track_tile.dart';

class RecommendedSection extends ConsumerWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedTracks = ref.watch(recommendedTracksProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 22,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'あなたへのおすすめ',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 260,
          child: recommendedTracks.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'おすすめトラックはまだありません',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final displayTracks = tracks.take(10).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                itemCount: displayTracks.length,
                itemExtent: 204, // 190 (card width) + 14 (margin)
                itemBuilder: (context, index) {
                  final track = displayTracks[index];
                  return HorizontalTrackCard(
                    track: track,
                    onTap: () {
                      context.go('/tracks/${track.id}', extra: track);
                    },
                  );
                },
              );
            },
            loading: () => const HorizontalTrackListSkeleton(),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_tethering_error,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'おすすめの読み込みに失敗しました',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        error.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.orange[900]),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () {
                          ref.invalidate(recommendedTracksProvider);
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FollowingFeedSection extends ConsumerWidget {
  const FollowingFeedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingFeedState = ref.watch(followingFeedControllerProvider);
    final theme = Theme.of(context);

    if (followingFeedState.items.isEmpty && !followingFeedState.isLoading) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'まだフォローしていません',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '気になるユーザーのプロフィールからフォローしてみましょう',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (followingFeedState.items.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people_rounded,
                    size: 22,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'フォロー中の新着',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              itemCount: followingFeedState.items.take(10).length,
              itemExtent: 204, // 190 (card width) + 14 (margin)
              itemBuilder: (context, index) {
                final item = followingFeedState.items[index];
                if (item.type == 'track' && item.track != null) {
                  return HorizontalTrackCard(
                    track: item.track!,
                    onTap: () {
                      context.go('/tracks/${item.track!.id}', extra: item.track);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class TrackListSection extends ConsumerWidget {
  const TrackListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksState = ref.watch(tracksControllerProvider);

    if (tracksState.error != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(
                    'エラーが発生しました',
                    style: TextStyle(color: Colors.red[900]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tracksState.error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(tracksControllerProvider.notifier).refresh();
                    },
                    child: const Text('再試行'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (tracksState.tracks.isEmpty && tracksState.isLoading) {
      return const SliverToBoxAdapter(
        child: TrackListSkeleton(itemCount: 5),
      );
    } else if (tracksState.tracks.isEmpty) {
      return SliverFillRemaining(
        child: Center(
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
                'トラックがありません',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < tracksState.tracks.length) {
              final track = tracksState.tracks[index];
              return CompactTrackTile(
                track: track,
                index: index + 1,
                onTap: () {
                  context.go('/tracks/${track.id}', extra: track);
                },
                onLike: () {
                  final notifier = ref.read(tracksControllerProvider.notifier);
                  if (track.isLiked) {
                    notifier.unlikeTrack(track.id);
                  } else {
                    notifier.likeTrack(track.id);
                  }
                },
              );
            } else if (tracksState.hasMore) {
              // Load more trigger
              Future.microtask(() {
                ref.read(tracksControllerProvider.notifier).loadMore();
              });
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          childCount: tracksState.tracks.length + (tracksState.hasMore ? 1 : 0),
        ),
      );
    }
  }
}
