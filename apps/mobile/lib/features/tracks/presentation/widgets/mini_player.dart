import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/audio/audio_player_controller.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use optimized provider - only rebuilds when track changes
    final currentTrack = ref.watch(audioCurrentTrackProvider);

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.go('/tracks/${currentTrack.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar - separate widget to isolate rebuilds
            const _ProgressBar(),

            // Player controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  // Artwork thumbnail with play indicator
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: currentTrack.artworkUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          memCacheWidth: 120,
                          placeholder: (context, url) => Container(
                            width: 56,
                            height: 56,
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
                            width: 56,
                            height: 56,
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
                              size: 28,
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ),
                      // Playing indicator - separate widget
                      const _PlayingIndicator(),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentTrack.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          currentTrack.artistName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Play/Pause button - separate widget
                  const _PlayPauseButton(),
                  const SizedBox(width: 8),

                  // Close button
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () async {
                        final controller = ref.read(
                          audioPlayerControllerProvider.notifier,
                        );
                        await controller.stop();
                      },
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
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

/// Progress bar widget - only rebuilds on position/duration changes
class _ProgressBar extends ConsumerWidget {
  const _ProgressBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(audioPositionProvider);
    final duration = ref.watch(audioDurationProvider);
    final theme = Theme.of(context);

    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: theme.colorScheme.surface,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Playing indicator overlay - only rebuilds on isPlaying changes
class _PlayingIndicator extends ConsumerWidget {
  const _PlayingIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final theme = Theme.of(context);

    if (!isPlaying) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.equalizer_rounded,
              color: Colors.white,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }
}

/// Play/Pause button - only rebuilds on isPlaying/isLoading changes
class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPlaying = ref.watch(audioIsPlayingProvider);
    final isLoading = ref.watch(audioIsLoadingProvider);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
        onPressed: () async {
          final controller = ref.read(audioPlayerControllerProvider.notifier);
          await controller.togglePlayPause();
        },
      ),
    );
  }
}
