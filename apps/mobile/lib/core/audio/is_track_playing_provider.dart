import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';

/// Provider to watch only if a specific track is currently playing
/// This avoids rebuilding all cards when audio position changes
final isTrackPlayingProvider = Provider.family<bool, String>((ref, trackId) {
  final audioState = ref.watch(audioPlayerControllerProvider.select(
    (state) => (state.currentTrack?.id == trackId, state.isPlaying),
  ));
  
  return audioState.$1 && audioState.$2;
});
