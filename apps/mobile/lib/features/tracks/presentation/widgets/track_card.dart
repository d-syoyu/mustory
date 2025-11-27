import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import '../../../../core/audio/audio_player_controller.dart';

class TrackCard extends ConsumerWidget {
  final Track track;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const TrackCard({
    super.key,
    required this.track,
    this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && audioState.isPlaying;
    final isLoading = isCurrentTrack && audioState.isLoading;
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Image with Playing Indicator
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: track.artworkUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    memCacheWidth: 600,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surfaceContainerHighest,
                            theme.colorScheme.surfaceContainerLow,
                          ],
                        ),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.colorScheme.surfaceContainerHighest,
                            theme.colorScheme.surfaceContainerLow,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 72,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Playing indicator overlay with blur effect
                  if (isPlaying)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.4),
                            ],
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.equalizer_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Story badge
                  if (track.hasStory)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Story',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Loading indicator
                  if (isLoading)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Track Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    track.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Artist Name
                  Text(
                    track.artistName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // User Info (if available)
                  if (track.user != null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        final router = GoRouter.of(context);
                        router.push('/users/${track.user!.id}');
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundImage: track.user!.avatarUrl != null
                                  ? NetworkImage(track.user!.avatarUrl!)
                                  : null,
                              child: track.user!.avatarUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 12,
                                      color: theme.colorScheme.primary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '@${track.user!.username}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              icon: Icons.favorite_rounded,
                              count: track.likeCount,
                              isHighlighted: track.isLiked,
                              theme: theme,
                            ),
                            _StatChip(
                              icon: Icons.chat_bubble_rounded,
                              count: track.trackCommentCount,
                              theme: theme,
                            ),
                            _StatChip(
                              icon: Icons.play_arrow_rounded,
                              count: track.viewCount,
                              theme: theme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: track.isLiked
                              ? Colors.red.withValues(alpha: 0.15)
                              : theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            track.isLiked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                          ),
                          onPressed: onLike,
                          color: track.isLiked
                              ? Colors.red
                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          iconSize: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat chip for displaying counts with icons
class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isHighlighted;
  final ThemeData theme;

  const _StatChip({
    required this.icon,
    required this.count,
    required this.theme,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = isHighlighted
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : theme.colorScheme.surface;
    final iconColor = isHighlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final textColor = isHighlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: iconColor,
          ),
          const SizedBox(width: 5),
          Text(
            _formatCount(count),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(0)}k';
    }
    return count.toString();
  }
}
