import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../features/tracks/application/tracks_controller.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tracksState = ref.watch(tracksControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mustory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ログアウト',
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(tracksControllerProvider.notifier).refresh();
              },
              child: CustomScrollView(
                slivers: [
                  // User info card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: authState.maybeWhen(
                        authenticated: (userId, email, displayName, _) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ようこそ、$displayNameさん',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ),
                  ),

                  // Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Text(
                        '新着トラック',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
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
                                // TODO: Navigate to track detail
                                context.go('/tracks/${track.id}');
                              },
                              onLike: () {
                                ref
                                    .read(tracksControllerProvider.notifier)
                                    .likeTrack(track.id);
                              },
                            );
                          } else if (tracksState.hasMore) {
                            // Load more trigger
                            ref.read(tracksControllerProvider.notifier).loadMore();
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
