import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Custom AudioHandler for background audio playback
/// Handles system media controls, notifications, and background playback
class MustoryAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  MustoryAudioHandler() {
    _init();
  }

  void _init() {
    // Listen to player state changes and update playback state
    _player.playbackEventStream.listen(_broadcastState);

    // Listen to processing state to detect when playback completes
    _player.processingStateStream.listen((processingState) {
      if (processingState == ProcessingState.completed) {
        // Optionally handle track completion (e.g., play next track)
        stop();
      }
    });
  }

  /// Broadcast current playback state to the system
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    ));
  }

  /// Play a track from URL with metadata
  Future<void> playFromUrl(
    String url, {
    required String id,
    required String title,
    required String artist,
    String? artworkUrl,
  }) async {
    // Set media item metadata for notification
    mediaItem.add(MediaItem(
      id: id,
      title: title,
      artist: artist,
      artUri: artworkUrl != null ? Uri.parse(artworkUrl) : null,
      duration: _player.duration,
    ));

    // Load and play audio
    await _player.setUrl(url);
    await _player.play();
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // TODO: Implement playlist/queue functionality
    // For now, just a placeholder
  }

  @override
  Future<void> skipToPrevious() async {
    // TODO: Implement playlist/queue functionality
    // For now, just a placeholder
  }

  /// Get the underlying AudioPlayer instance
  AudioPlayer get player => _player;

  /// Clean up resources
  Future<void> dispose() async {
    await _player.dispose();
  }
}
