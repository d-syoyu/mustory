import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../features/tracks/application/recommended_tracks_provider.dart';
import '../../../features/tracks/application/tracks_controller.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/horizontal_track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/profile/application/profile_controller.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracksState = ref.watch(tracksControllerProvider);
    final recommendedTracks = ref.watch(recommendedTracksProvider);
    final followingFeedState = ref.watch(followingFeedControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mustory',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  ref.read(tracksControllerProvider.notifier).refresh(),
                  ref.refresh(recommendedTracksProvider.future),
                  ref.read(followingFeedControllerProvider.notifier).loadFeed(refresh: true),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                  // おすすめセクション (横スクロールカルーセル)
                  SliverToBoxAdapter(
                    child: Column(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Card(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'おすすめトラックはまだありません',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
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
                                itemBuilder: (context, index) {
                                  final track = displayTracks[index];
                                  return HorizontalTrackCard(
                                    track: track,
                                    onTap: () {
                                      context.go('/tracks/${track.id}');
                                    },
                                  );
                                },
                              );
                            },
                            loading: () => const HorizontalTrackListSkeleton(),
                            error: (error, _) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                color: Colors.orange[50],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.wifi_tethering_error,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'おすすめの読み込みに失敗しました',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        error.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: Colors.orange[900]),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: () {
                                          ref.refresh(
                                              recommendedTracksProvider);
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
                    ),
                  ),

                  // フォロー中の新着セクション
                  if (followingFeedState.items.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Column(
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
                              itemBuilder: (context, index) {
                                final item = followingFeedState.items[index];
                                if (item.type == 'track' && item.track != null) {
                                  return HorizontalTrackCard(
                                    track: item.track!,
                                    onTap: () {
                                      context.go('/tracks/${item.track!.id}');
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                  // フォロー中が空の場合の案内
                  if (followingFeedState.items.isEmpty && !followingFeedState.isLoading)
                    SliverToBoxAdapter(
                      child: Padding(
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
                      ),
                    ),

                  // 今日の注目 Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.red.shade600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '今日の注目',
                            style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Error State
                  if (tracksState.error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.red[50],
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red),
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
                                    ref
                                        .read(tracksControllerProvider.notifier)
                                        .refresh();
                                  },
                                  child: const Text('再試行'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Tracks List
                  if (tracksState.tracks.isEmpty && tracksState.isLoading)
                    const SliverToBoxAdapter(
                      child: TrackListSkeleton(itemCount: 5),
                    )
                  else if (tracksState.tracks.isEmpty)
                    SliverFillRemaining(
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
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < tracksState.tracks.length) {
                            final track = tracksState.tracks[index];
                            return TrackCard(
                              track: track,
                              onTap: () {
                                context.go('/tracks/${track.id}');
                              },
                              onLike: () {
                                final notifier =
                                    ref.read(tracksControllerProvider.notifier);
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
                              ref
                                  .read(tracksControllerProvider.notifier)
                                  .loadMore();
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
                        childCount: tracksState.tracks.length +
                            (tracksState.hasMore ? 1 : 0),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Mini player at bottom
          const MiniPlayer(),
        ],
      ),
    );
  }
}
