import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/application/recommended_tracks_provider.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';

void main() {
  group('recommendedTracksProvider', () {
    test('returns tracks from repository with expected limit', () async {
      final repository = _FakeTracksRepository([
        const Track(
          id: 'track-1',
          title: 'Story Hero',
          artistName: 'Creator A',
          userId: 'user-1',
          artworkUrl: 'https://example.com/art-1.png',
          hlsUrl: 'https://example.com/audio-1.m3u8',
          likeCount: 10,
          viewCount: 100,
        ),
        const Track(
          id: 'track-2',
          title: 'Indie Fresh',
          artistName: 'Creator B',
          userId: 'user-2',
          artworkUrl: 'https://example.com/art-2.png',
          hlsUrl: 'https://example.com/audio-2.m3u8',
          likeCount: 4,
          viewCount: 20,
        ),
      ]);

      final container = ProviderContainer(overrides: [
        tracksRepositoryProvider.overrideWithValue(repository),
      ]);
      addTearDown(container.dispose);

      final tracks = await container.read(recommendedTracksProvider.future);

      expect(tracks, hasLength(2));
      expect(tracks.first.title, 'Story Hero');
      expect(repository.requestedLimit, 12);
    });

    test('propagates repository errors', () async {
      final container = ProviderContainer(overrides: [
        tracksRepositoryProvider.overrideWithValue(_FailingTracksRepository()),
      ]);
      addTearDown(container.dispose);

      expect(
        container.read(recommendedTracksProvider.future),
        throwsA(isA<Exception>()),
      );
    });
  });
}

class _FakeTracksRepository extends TracksRepository {
  _FakeTracksRepository(this._tracks) : super(Dio());

  final List<Track> _tracks;
  int requestedLimit = 0;

  @override
  Future<List<Track>> getRecommendedTracks({int limit = 20}) async {
    requestedLimit = limit;
    return _tracks;
  }
}

class _FailingTracksRepository extends TracksRepository {
  _FailingTracksRepository() : super(Dio());

  @override
  Future<List<Track>> getRecommendedTracks({int limit = 20}) {
    throw Exception('network error');
  }
}
