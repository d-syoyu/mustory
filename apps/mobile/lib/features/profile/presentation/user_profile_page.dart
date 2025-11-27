import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/audio/audio_player_controller.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../application/profile_controller.dart';
import '../../tracks/domain/track.dart';
import '../../story/domain/story.dart';

class UserProfilePage extends HookConsumerWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider(userId));
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final profile = profileState.profile;
    final currentUserId = authState.maybeWhen(
      authenticated: (uid, _, __, ___) => uid,
      orElse: () => null,
    );
    final isSelf = profile != null && currentUserId == profile.id;

    if (profileState.isLoading && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('プロフィール')),
        body: const ProfileSkeleton(),
      );
    }

    if (profileState.error != null && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('プロフィール')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(profileControllerProvider(userId).notifier)
                      .loadProfile();
                },
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider(userId).notifier)
              .loadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile?.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile != null)
                      Text(
                        '@${profile.username}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      profile?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          profile.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (profile?.location != null && profile!.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile.location!,
                              style: const TextStyle(color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (profile?.linkUrl != null && profile!.linkUrl!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              profile.linkUrl!,
                              style: const TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isSelf && profile != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(
                                    profileControllerProvider(userId).notifier)
                                .toggleFollow();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: profile.isFollowedByMe
                                ? Colors.white
                                : theme.colorScheme.secondary,
                            foregroundColor: profile.isFollowedByMe
                                ? theme.colorScheme.primary
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(profile.isFollowedByMe
                              ? Icons.favorite
                              : Icons.favorite_border),
                          label:
                              Text(profile.isFollowedByMe ? 'フォロー中' : 'フォローする'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatChip(
                              label: 'フォロワー',
                              value: profile?.followerCount ?? 0,
                              onTap: () => context.push('/users/$userId/followers'),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            _StatChip(
                              label: 'フォロー中',
                              value: profile?.followingCount ?? 0,
                              onTap: () => context.push('/users/$userId/following'),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            _StatChip(
                              label: 'トラック',
                              value: profile?.trackCount ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Profile tabs with actual data
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'トラック'),
                        Tab(text: '物語'),
                        Tab(text: 'いいね'),
                      ],
                    ),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [
                          _UserTracksTab(userId: userId),
                          _UserStoriesTab(userId: userId),
                          _UserLikedTracksTab(userId: userId),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// User Tracks Tab
class _UserTracksTab extends ConsumerWidget {
  final String userId;

  const _UserTracksTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userTracksControllerProvider(userId));
    final theme = Theme.of(context);

    if (state.isLoading && state.tracks.isEmpty) {
      return const ProfileTrackListSkeleton(itemCount: 5);
    }

    if (state.error != null && state.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userTracksControllerProvider(userId).notifier).loadTracks(),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.library_music,
        message: 'まだトラックがありません',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.tracks.length,
      itemBuilder: (context, index) {
        final track = state.tracks[index];
        return _ProfileTrackTile(
          track: track,
          onTap: () => context.push('/tracks/${track.id}'),
        );
      },
    );
  }
}

// User Stories Tab
class _UserStoriesTab extends ConsumerWidget {
  final String userId;

  const _UserStoriesTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userStoriesControllerProvider(userId));
    final theme = Theme.of(context);

    if (state.isLoading && state.stories.isEmpty) {
      return const ProfileTrackListSkeleton(itemCount: 5);
    }

    if (state.error != null && state.stories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userStoriesControllerProvider(userId).notifier).loadStories(),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }

    if (state.stories.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.menu_book_rounded,
        message: 'まだ物語がありません',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.stories.length,
      itemBuilder: (context, index) {
        final story = state.stories[index];
        return _ProfileStoryTile(
          story: story,
          onTap: () => context.push('/tracks/${story.trackId}'),
        );
      },
    );
  }
}

// User Liked Tracks Tab
class _UserLikedTracksTab extends ConsumerWidget {
  final String userId;

  const _UserLikedTracksTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userLikedTracksControllerProvider(userId));
    final theme = Theme.of(context);

    if (state.isLoading && state.tracks.isEmpty) {
      return const ProfileTrackListSkeleton(itemCount: 5);
    }

    if (state.error != null && state.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(userLikedTracksControllerProvider(userId).notifier).loadLikedTracks(),
              child: const Text('再読み込み'),
            ),
          ],
        ),
      );
    }

    if (state.tracks.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.favorite,
        message: 'まだいいねしたトラックがありません',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.tracks.length,
      itemBuilder: (context, index) {
        final track = state.tracks[index];
        return _ProfileTrackTile(
          track: track,
          onTap: () => context.push('/tracks/${track.id}'),
        );
      },
    );
  }
}

Widget _buildEmptyState(BuildContext context, {required IconData icon, required String message}) {
  final theme = Theme.of(context);
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48, color: theme.colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          message,
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    ),
  );
}

// Track tile for profile tabs
class _ProfileTrackTile extends ConsumerWidget {
  final Track track;
  final VoidCallback? onTap;

  const _ProfileTrackTile({required this.track, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && audioState.isPlaying;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: track.artworkUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 56,
                  height: 56,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note),
                ),
              ),
              if (isPlaying)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.equalizer, color: Colors.white),
                ),
            ],
          ),
        ),
        title: Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isCurrentTrack ? FontWeight.bold : FontWeight.normal,
            color: isCurrentTrack ? theme.colorScheme.primary : null,
          ),
        ),
        subtitle: Text(
          track.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (track.hasStory)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.menu_book, size: 12, color: theme.colorScheme.primary),
                    const SizedBox(width: 2),
                    Text(
                      '物語',
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              track.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: track.isLiked ? Colors.red : theme.colorScheme.outline,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

// Story tile for profile tabs
class _ProfileStoryTile extends StatelessWidget {
  final Story story;
  final VoidCallback? onTap;

  const _ProfileStoryTile({required this.story, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.menu_book_rounded,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          story.lead,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Icon(Icons.favorite, size: 14, color: theme.colorScheme.outline),
            const SizedBox(width: 4),
            Text('${story.likeCount}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onTap;

  const _StatChip({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: content,
      ),
    );
  }
}
