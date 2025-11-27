import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/analytics/analytics_service.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/core/auth/auth_repository.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';
import 'package:mustory_mobile/features/tracks/presentation/track_detail_page.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  testWidgets('TrackDetailPage shows track info and tabs', (tester) async {
    final repository = _FakeTracksRepository();
    final analyticsService = _FakeAnalyticsService();
    final audioController = _FakeAudioPlayerController(repository, analyticsService);
    final authRepository = _FakeAuthRepository();

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tracksRepositoryProvider.overrideWithValue(repository),
            analyticsServiceProvider.overrideWithValue(analyticsService),
            audioPlayerControllerProvider.overrideWith((ref) => audioController),
            authRepositoryProvider.overrideWithValue(authRepository),
          ],
          child: const MaterialApp(
            home: TrackDetailPage(trackId: 'track-1'),
          ),
        ),
      );

      // Initial loading state might be fast, so we might miss it if we don't check immediately
      // But loadTrackDetail is async.
      
      // Pump to allow Future to complete
      await tester.pump(const Duration(seconds: 2));

      // Check if track info is displayed
      expect(find.text('Demo'), findsOneWidget);
      expect(find.text('Tester'), findsOneWidget);

      // Check tabs
      expect(find.text('曲'), findsOneWidget);
      expect(find.text('ストーリー'), findsOneWidget);

      // Check player controls
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}

class _FakeTracksRepository extends TracksRepository {
  _FakeTracksRepository() : super(Dio());

  final TrackDetail _detail = const TrackDetail(
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
  Future<void> incrementViewCount(String trackId) async {}
}

class _FakeAnalyticsService extends AnalyticsService {
  @override
  Future<void> track(String event, {Map<String, dynamic>? properties}) async {}
  
  @override
  Future<void> logTrackPlayed(String trackId) async {}
  
  @override
  Future<void> logStoryExpanded(String trackId, String storyId) async {}
}

class _FakeAudioPlayerController extends AudioPlayerController {
  _FakeAudioPlayerController(
    TracksRepository repository,
    AnalyticsService analyticsService,
  ) : super(repository, analyticsService, testMode: true);

  @override
  Future<void> playTrack(Track track) async {
    state = state.copyWith(
      currentTrack: track,
      isPlaying: true,
      isLoading: false,
    );
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  User? get currentUser => null;

  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<AuthResponse> signUp({required String email, required String password, required String displayName}) async {
    throw UnimplementedError();
  }
  
  @override
  Future<AuthResponse> refreshSession() async {
    throw UnimplementedError();
  }

  @override
  String? get accessToken => null;
}
