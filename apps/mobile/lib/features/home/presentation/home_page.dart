import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';
import 'package:mustory_mobile/core/ui/app_palettes.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../features/tracks/application/tracks_controller.dart';
import '../../../features/tracks/domain/track.dart';
import '../../../features/tracks/presentation/widgets/mini_player.dart';
import '../../../features/tracks/presentation/widgets/track_card.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final tracksState = ref.watch(tracksControllerProvider);
    final highlightTrack =
        tracksState.tracks.isNotEmpty ? tracksState.tracks.first : null;

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05050A), Color(0xFF15182A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref.read(tracksControllerProvider.notifier).refresh();
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      floating: true,
                      snap: true,
                      titleSpacing: 16,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ようこそ、Mustoryへ',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Mustory',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: _HeroSection(
                          displayName: authState.maybeWhen(
                            authenticated: (_, __, displayName, ___) => displayName,
                            orElse: () => 'Creator',
                          ),
                          track: highlightTrack,
                          onPlay: highlightTrack == null
                              ? null
                              : () async {
                                  final controller =
                                      ref.read(audioPlayerControllerProvider.notifier);
                                  await controller.playTrack(highlightTrack);
                                },
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: authState.maybeWhen(
                          authenticated: (_, email, displayName, __) => _GlassCard(
                            title: displayName,
                            subtitle: email,
                            icon: Icons.person,
                            action: TextButton(
                              onPressed: () => context.go('/profile'),
                              child: const Text('マイページ'),
                            ),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: _QuickChips(
                          onUpload: () => context.go('/profile/upload'),
                          onSearch: () => context.go('/search'),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _TrendingTags(),
                      ),
                    ),
                    if (tracksState.error != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: _ErrorCard(
                            message: tracksState.error!,
                            onRetry: () => ref
                                .read(tracksControllerProvider.notifier)
                                .refresh(),
                          ),
                        ),
                      ),
                    if (tracksState.tracks.isEmpty && tracksState.isLoading)
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (tracksState.tracks.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.music_note, size: 72, color: Colors.white24),
                              const SizedBox(height: 16),
                              Text(
                                'まだトラックがありません。\n最初の一歩を踏み出しましょう。',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
                          child: Text(
                            '最新トラック',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index < tracksState.tracks.length) {
                              final track = tracksState.tracks[index];
                              return TrackCard(
                                track: track,
                                onTap: () => context.go('/tracks/${track.id}'),
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
                              Future.microtask(() {
                                ref.read(tracksControllerProvider.notifier).loadMore();
                              });
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          childCount:
                              tracksState.tracks.length + (tracksState.hasMore ? 1 : 0),
                        ),
                      ),
                    ],
                    const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                  ],
                ),
              ),
            ),
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.displayName,
    required this.track,
    required this.onPlay,
  });

  final String displayName;
  final Track? track;
  final Future<void> Function()? onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.softGlow,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'こんにちは、$displayName さん',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            '物語とサウンドで夜を彩ろう',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (track != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    track!.artworkUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track!.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        track!.artistName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('再生'),
                ),
              ],
            )
          else
            FilledButton.icon(
              onPressed: onPlay,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('最初の物語を投稿'),
            ),
        ],
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({
    required this.onUpload,
    required this.onSearch,
  });

  final VoidCallback onUpload;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _ActionChip(
          icon: Icons.cloud_upload_outlined,
          label: 'トラックをアップロード',
          onTap: onUpload,
        ),
        _ActionChip(
          icon: Icons.book_outlined,
          label: '物語を書く',
          onTap: () {},
        ),
        _ActionChip(
          icon: Icons.search,
          label: '気分で探す',
          onTap: onSearch,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _TrendingTags extends StatelessWidget {
  final List<String> tags = const [
    '#MidnightVibes',
    '#LoFi',
    '#CityPop',
    '#Chillhop',
    '#EpicStory',
    '#WeekendDrive',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending tags',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map(
                (tag) => Chip(
                  label: Text(tag),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.red.withValues(alpha: 0.12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            'フィードの取得に失敗しました',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('再読み込み'),
          ),
        ],
      ),
    );
  }
}
