import 'package:audio_session/audio_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final audioPlayerControllerProvider = Provider<AudioPlayerController>(
  (ref) {
    final controller = AudioPlayerController._();
    ref.onDispose(controller.dispose);
    return controller;
  },
);

class AudioPlayerController {
  AudioPlayerController._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();

  Future<void> dispose() => _player.dispose();

  AudioPlayer get player => _player;
}
