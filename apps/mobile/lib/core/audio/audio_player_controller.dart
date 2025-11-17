import 'package:audio_session/audio_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/tracks/domain/track.dart';

part 'audio_player_controller.freezed.dart';

@freezed
class AudioPlayerState with _$AudioPlayerState {
  const factory AudioPlayerState({
    Track? currentTrack,
    @Default(false) bool isPlaying,
    @Default(Duration.zero) Duration position,
    @Default(Duration.zero) Duration duration,
    @Default(false) bool isLoading,
  }) = _AudioPlayerState;
}

class AudioPlayerController extends StateNotifier<AudioPlayerState> {
  AudioPlayerController() : super(const AudioPlayerState()) {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  void _init() {
    _configureSession();

    // Listen to player state
    _player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
                   playerState.processingState == ProcessingState.buffering,
      );
    });

    // Listen to position
    _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration
    _player.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> playTrack(Track track) async {
    try {
      state = state.copyWith(isLoading: true);

      // If the same track is already loaded, just play it
      if (state.currentTrack?.id == track.id && _player.audioSource != null) {
        await _player.play();
        return;
      }

      // Load and play new track
      state = state.copyWith(currentTrack: track);
      await _player.setUrl(track.hlsUrl);
      await _player.play();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(
      currentTrack: null,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  AudioPlayer get player => _player;
}

// Provider
final audioPlayerControllerProvider =
    StateNotifierProvider<AudioPlayerController, AudioPlayerState>((ref) {
  return AudioPlayerController();
});

final audioPlayerStateProvider = Provider<AudioPlayerState>((ref) {
  return ref.watch(audioPlayerControllerProvider);
});
