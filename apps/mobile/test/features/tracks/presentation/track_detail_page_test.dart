import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/features/tracks/application/track_detail_controller.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/comment.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';
import 'package:mustory_mobile/features/tracks/presentation/track_detail_page.dart';

void main() {
  testWidgets('Track detail renders story/comment tabs', (tester) async {
    final story = {
      'id': 'story-1',
      'lead': '夜の散歩道',
      'body': '柔らかな風が物語を運ぶ――この曲が生まれた背景です。',
    };

    final detail = TrackDetail(
      track: Track(
        id: 'track-1',
        title: 'Night Walk',
        artistName: 'LoFi Creator',
        userId: 'author-1',
        artworkUrl: 'https://example.com/art.png',
        hlsUrl: 'https://example.com/audio.m3u8',
        isLiked: false,
        likeCount: 12,
        story: story,
      ),
      storyComments: [
        Comment(
          id: 'comment-1',
          authorUserId: 'u1',
          authorDisplayName: 'Listener',
          body: 'この物語好きです！',
          createdAt: DateTime(2025, 1, 1),
          targetType: 'story',
          targetId: 'story-1',
        ),
      ],
      trackComments: [
        Comment(
          id: 'comment-2',
          authorUserId: 'u2',
          authorDisplayName: 'Another',
          body: 'メロディが最高でした',
          createdAt: DateTime(2025, 1, 1),
          targetType: 'track',
          targetId: 'track-1',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          trackDetailControllerProvider.overrideWith(
            (ref, trackId) => _FakeTrackDetailController(detail),
          ),
          audioPlayerStateProvider.overrideWith((ref) => const AudioPlayerState()),
          currentUserIdProvider.overrideWith((ref) => 'author-1'),
        ],
        child: const MaterialApp(
          home: TrackDetailPage(trackId: 'track-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('物語'), findsOneWidget);
    expect(find.text('コメント'), findsOneWidget);
    expect(find.textContaining('物語のコメント'), findsOneWidget);

    await tester.tap(find.text('コメント'));
    await tester.pumpAndSettle();

    expect(find.textContaining('トラックへのコメント'), findsOneWidget);
  });
}

class _FakeTrackDetailController extends TrackDetailController {
  _FakeTrackDetailController(this._detail)
      : super(_FakeTracksRepository(), _detail.track.id) {
    state = TrackDetailState(trackDetail: _detail, isLoading: false);
  }

  final TrackDetail _detail;

  @override
  Future<void> loadTrackDetail() async {}
}

class _FakeTracksRepository extends TracksRepository {
  _FakeTracksRepository() : super(Dio());
}
