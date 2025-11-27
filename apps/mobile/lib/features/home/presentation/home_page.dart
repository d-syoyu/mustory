import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../features/tracks/application/recommended_tracks_provider.dart';
import '../../../features/tracks/application/tracks_controller.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/profile/application/profile_controller.dart';
import 'widgets/home_sections.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  const SliverToBoxAdapter(
                    child: RecommendedSection(),
                  ),

                  // フォロー中の新着セクション
                  const SliverToBoxAdapter(
                    child: FollowingFeedSection(),
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

                  // Tracks List
                  const TrackListSection(),
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
