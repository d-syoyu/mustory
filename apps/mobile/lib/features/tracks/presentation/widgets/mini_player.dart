import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/audio/audio_player_controller.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final currentTrack = audioState.currentTrack;

    if (currentTrack == null) {
      return const SizedBox.shrink();
    }

    final progress = audioState.duration.inMilliseconds > 0
        ? audioState.position.inMilliseconds / audioState.duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: progress,
            minHeight: 2,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          // Player controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Artwork thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    currentTrack.artworkUrl,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey[300],
                        child: const Icon(Icons.music_note, size: 24),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Track info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentTrack.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentTrack.artistName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Time display
                Text(
                  '${_formatDuration(audioState.position)} / ${_formatDuration(audioState.duration)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),

                // Play/Pause button
                IconButton(
                  icon: audioState.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                  onPressed: () async {
                    final controller = ref.read(
                      audioPlayerControllerProvider.notifier,
                    );
                    await controller.togglePlayPause();
                  },
                ),

                // Stop button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    final controller = ref.read(
                      audioPlayerControllerProvider.notifier,
                    );
                    await controller.stop();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
