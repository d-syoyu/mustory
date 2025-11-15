import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/models/track.dart';
import 'package:mustory_mobile/features/track_detail/application/track_detail_controller.dart';
import 'package:mustory_mobile/features/track_detail/data/track_detail_repository.dart';
import 'package:mustory_mobile/features/track_detail/presentation/track_detail_page.dart';

void main() {
  testWidgets('shows track detail tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackDetailRepositoryProvider.overrideWithValue(
            _FakeTrackDetailRepository(),
          ),
        ],
        child: const MaterialApp(
          home: TrackDetailPage(trackId: 'demo-track'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('物語'), findsOneWidget);
    expect(find.text('コメント'), findsOneWidget);
  });
}

class _FakeTrackDetailRepository extends TrackDetailRepository {
  static const _story = Story(
    id: 'story-1',
    trackId: 'demo-track',
    lead: 'デモリード',
    body: 'これはテスト用の物語本文です。',
    isLiked: false,
    likeCount: 0,
  );

  static final _track = Track(
    id: 'demo-track',
    title: 'Demo Track',
    artistName: 'Tester',
    artworkUrl: 'https://example.com/artwork.png',
    hlsUrl: 'https://example.com/audio.m3u8',
    isLiked: false,
    likeCount: 0,
    story: _story,
  );

  @override
  Future<Track> fetchTrack(String trackId) async => _track;

  @override
  Future<List<Comment>> fetchTrackComments(String trackId) async => [
        Comment(
          id: 'c1',
          authorDisplayName: 'Listener',
          body: 'Great song!',
          createdAt: DateTime(2025),
          targetType: CommentTargetType.track,
        ),
      ];

  @override
  Future<List<Comment>> fetchStoryComments(String storyId) async => [
        Comment(
          id: 's1',
          authorDisplayName: 'Reader',
          body: 'Nice story!',
          createdAt: DateTime(2025),
          targetType: CommentTargetType.story,
        ),
      ];

  @override
  Future<void> postComment({
    required CommentTargetType targetType,
    required String targetId,
    required String body,
  }) async {}
}
