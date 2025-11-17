import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Image with Play Button Overlay
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: track.artworkUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(
                        Icons.music_note,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Play/Pause Button Overlay
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        iconSize: 48,
                        icon: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          final controller = ref.read(
                            audioPlayerControllerProvider.notifier,
                          );
                          if (isCurrentTrack) {
                            await controller.togglePlayPause();
                          } else {
                            await controller.playTrack(track);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Track Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Artist Name
                  Text(
                    track.artistName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Stats Row
                  Row(
                    children: [
                      // Views (play count) - placeholder for now
                      Icon(
                        Icons.remove_red_eye,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '0', // TODO: Add plays_count to Track model
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(width: 12),

                      // Comments - placeholder for now
                      Icon(
                        Icons.comment,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '0', // TODO: Add comments_count to Track model
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(width: 12),

                      // Like Count
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${track.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(width: 12),

                      // Story Indicator
                      if (track.hasStory) ...[
                        Icon(
                          Icons.book,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],

                      const Spacer(),

                      // Like Button
                      IconButton(
                        icon: Icon(
                          track.isLiked ? Icons.favorite : Icons.favorite_border,
                        ),
                        onPressed: onLike,
                        color: track.isLiked
                            ? Colors.red
                            : Theme.of(context).colorScheme.primary,
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
