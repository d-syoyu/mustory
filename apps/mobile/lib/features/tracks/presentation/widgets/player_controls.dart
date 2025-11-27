import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../core/audio/audio_player_controller.dart';
import '../../domain/track.dart';

class PlayerProgressControl extends ConsumerWidget {
  const PlayerProgressControl({
    super.key,
    required this.trackId,
  });

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final isCurrentTrack = audioState.currentTrack?.id == trackId;

    if (!isCurrentTrack) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 3,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 6,
                ),
              ),
              child: Slider(
                value: 0,
                max: 1,
                onChanged: null,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0:00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                  Text(
                    '0:00',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: RoundSliderOverlayShape(
                overlayRadius: 14,
              ),
            ),
            child: Slider(
              value: audioState.position.inSeconds.toDouble().clamp(
                    0.0,
                    audioState.duration.inSeconds.toDouble() > 0
                        ? audioState.duration.inSeconds.toDouble()
                        : 1.0,
                  ),
              max: audioState.duration.inSeconds.toDouble() > 0
                  ? audioState.duration.inSeconds.toDouble()
                  : 1.0,
              onChanged: (value) {
                ref
                    .read(audioPlayerControllerProvider.notifier)
                    .seek(Duration(seconds: value.toInt()));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(audioState.position),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
                Text(
                  audioState.duration.inSeconds > 0
                      ? '-${_formatDuration(audioState.duration - audioState.position)}'
                      : '0:00',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class PlayerActionButtons extends ConsumerWidget {
  const PlayerActionButtons({
    super.key,
    required this.track,
  });

  final Track track;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerControllerProvider);
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && audioState.isPlaying;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.skip_previous),
          onPressed: () {
            // TODO: 前の曲へ
          },
        ),
        const SizedBox(width: 24),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: audioState.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : IconButton(
                  iconSize: 32,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    final controller =
                        ref.read(audioPlayerControllerProvider.notifier);
                    if (isCurrentTrack) {
                      await controller.togglePlayPause();
                    } else {
                      await controller.playTrack(track);
                    }
                  },
                ),
        ),
        const SizedBox(width: 24),
        IconButton(
          iconSize: 32,
          icon: const Icon(Icons.skip_next),
          onPressed: () {
            // TODO: 次の曲へ
          },
        ),
      ],
    );
  }
}
