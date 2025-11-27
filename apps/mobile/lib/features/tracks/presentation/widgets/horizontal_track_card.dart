import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import '../../../../core/audio/is_track_playing_provider.dart';

/// Horizontal track card for carousel display
class HorizontalTrackCard extends ConsumerWidget {
  final Track track;
  final VoidCallback? onTap;

  const HorizontalTrackCard({
    super.key,
    required this.track,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch if THIS specific track is playing, not the entire audio state
    final isPlaying = ref.watch(isTrackPlayingProvider(track.id));
    final theme = Theme.of(context);

    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork with play indicator
            Hero(
              tag: 'track-artwork-${track.id}',
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                    imageUrl: track.artworkUrl,
                    height: 190,
                    width: 190,
                    memCacheWidth: 400,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 190,
                      width: 190,
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
                      height: 190,
                      width: 190,
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
                        size: 56,
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),

                // Play indicator overlay
                if (isPlaying)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.equalizer_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Story badge
                if (track.hasStory)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              track.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // Artist
            Text(
              track.artistName,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // User Info (if available)
            if (track.user != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  context.push('/users/${track.user!.id}');
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 8,
                      backgroundImage: track.user!.avatarUrl != null
                          ? NetworkImage(track.user!.avatarUrl!)
                          : null,
                      child: track.user!.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 8,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '@${track.user!.username}',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
