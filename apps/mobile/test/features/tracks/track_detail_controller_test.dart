import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mustory_mobile/core/analytics/analytics_service.dart';
import 'package:mustory_mobile/features/tracks/application/track_detail_controller.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';

void main() {
  group('TrackDetailController', () {
    late _FakeTracksRepository repository;
    late _FakeAnalyticsService analyticsService;
    late TrackDetailController controller;

    setUp(() {
      repository = _FakeTracksRepository();
      analyticsService = _FakeAnalyticsService();
      controller = TrackDetailController(repository, analyticsService, 'track-1');
    });

    test('loadTrackDetail populates state', () async {
      await controller.loadTrackDetail();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.trackDetail, isNotNull);
      expect(controller.state.trackDetail!.track.id, 'track-1');
      expect(controller.state.trackDetail!.trackComments, isEmpty);
      expect(controller.state.trackDetail!.storyComments, isEmpty);
    });

    test('likeTrack updates local like count', () async {
      await controller.loadTrackDetail();

      final initialCount = controller.state.trackDetail!.track.likeCount;
      await controller.likeTrack();

      expect(repository.likeCalls, 1);
      expect(controller.state.trackDetail!.track.likeCount, initialCount + 1);
      expect(controller.state.trackDetail!.track.isLiked, isTrue);
    });
  });
}

class _FakeTracksRepository extends TracksRepository {
  _FakeTracksRepository() : super(Dio());

  int likeCalls = 0;

  TrackDetail _detail = const TrackDetail(
    track: Track(
      id: 'track-1',
      title: 'Demo',
      artistName: 'Tester',
      userId: 'user-1',
      artworkUrl: 'https://example.com/artwork.png',
      hlsUrl: 'https://example.com/audio.m3u8',
      likeCount: 2,
      isLiked: false,
      story: {
        'id': 'story-1',
        'track_id': 'track-1',
        'author_user_id': 'user-1',
        'lead': 'Lead',
        'body': 'Body',
        'like_count': 0,
        'is_liked': false,
      },
    ),
    trackComments: [],
    storyComments: [],
  );

  @override
  Future<TrackDetail> getTrackDetail(String id, {bool forceRefresh = false}) async {
    return _detail;
  }

  @override
  Future<void> likeTrack(String trackId) async {
    likeCalls += 1;
    _detail = _detail.copyWith(
      track: _detail.track.copyWith(
        likeCount: _detail.track.likeCount + 1,
        isLiked: true,
      ),
    );
  }

  @override
  Future<void> unlikeTrack(String trackId) async {
    _detail = _detail.copyWith(
      track: _detail.track.copyWith(
        likeCount: _detail.track.likeCount > 0 ? _detail.track.likeCount - 1 : 0,
        isLiked: false,
      ),
    );
  }
}

class _FakeAnalyticsService extends AnalyticsService {
  @override
  Future<void> track(String event, {Map<String, dynamic>? properties}) async {}
}
