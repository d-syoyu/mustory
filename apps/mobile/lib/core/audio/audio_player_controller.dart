import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/tracks/domain/track.dart';
import '../../features/tracks/data/tracks_repository.dart';
import '../../features/tracks/application/tracks_controller.dart';
import 'audio_handler.dart';

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
  AudioPlayerController(this._tracksRepository) : super(const AudioPlayerState()) {
    _init();
  }

  final TracksRepository _tracksRepository;
  MustoryAudioHandler? _audioHandler;

  Future<void> _init() async {
    await _configureSession();

    // Initialize audio handler for background playback
    _audioHandler = await AudioService.init(
      builder: () => MustoryAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mustory.app.audio',
        androidNotificationChannelName: 'Mustory Audio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    // Listen to player state from audio handler
    _audioHandler!.player.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
                   playerState.processingState == ProcessingState.buffering,
      );
    });

    // Listen to position
    _audioHandler!.player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration
    _audioHandler!.player.durationStream.listen((duration) {
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
    if (_audioHandler == null) {
      throw Exception('Audio handler not initialized');
    }

    try {
      state = state.copyWith(isLoading: true);

      // If the same track is already loaded, just play it
      if (state.currentTrack?.id == track.id &&
          _audioHandler!.player.audioSource != null) {
        await _audioHandler!.play();
        return;
      }

      // Load and play new track with metadata for notification
      state = state.copyWith(currentTrack: track);
      await _audioHandler!.playFromUrl(
        track.hlsUrl,
        id: track.id,
        title: track.title,
        artist: track.artistName,
        artworkUrl: track.artworkUrl,
      );

      // Increment view count when track starts playing
      // Fire and forget - don't wait for completion
      _tracksRepository.incrementViewCount(track.id);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioHandler == null) return;

    if (state.isPlaying) {
      await _audioHandler!.pause();
    } else {
      await _audioHandler!.play();
    }
  }

  Future<void> pause() async {
    if (_audioHandler == null) return;
    await _audioHandler!.pause();
  }

  Future<void> seek(Duration position) async {
    if (_audioHandler == null) return;
    await _audioHandler!.seek(position);
  }

  Future<void> stop() async {
    if (_audioHandler == null) return;

    await _audioHandler!.stop();
    state = state.copyWith(
      currentTrack: null,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  @override
  void dispose() {
    _audioHandler?.dispose();
    super.dispose();
  }

  AudioPlayer? get player => _audioHandler?.player;
}

// Provider
final audioPlayerControllerProvider =
    StateNotifierProvider<AudioPlayerController, AudioPlayerState>((ref) {
  // Import the tracksRepositoryProvider from tracks_controller
  final tracksRepository = ref.watch(tracksRepositoryProvider);
  return AudioPlayerController(tracksRepository);
});
