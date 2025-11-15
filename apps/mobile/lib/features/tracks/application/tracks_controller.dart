import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/network/api_client.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';

// Repository Provider
final tracksRepositoryProvider = Provider<TracksRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TracksRepository(dio);
});

// Tracks List State
class TracksState {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  TracksState({
    this.tracks = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  TracksState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return TracksState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Tracks Controller
class TracksController extends StateNotifier<TracksState> {
  final TracksRepository _repository;
  static const int _pageSize = 20;

  TracksController(this._repository) : super(TracksState()) {
    loadTracks();
  }

  Future<void> loadTracks({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = TracksState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final offset = refresh ? 0 : state.tracks.length;
      final newTracks = await _repository.getTracks(
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = TracksState(
          tracks: newTracks,
          isLoading: false,
          hasMore: newTracks.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          tracks: [...state.tracks, ...newTracks],
          isLoading: false,
          hasMore: newTracks.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadTracks();
  }

  Future<void> refresh() async {
    await loadTracks(refresh: true);
  }

  Future<void> likeTrack(String trackId) async {
    try {
      await _repository.likeTrack(trackId);

      // Update local state
      final updatedTracks = state.tracks.map((track) {
        if (track.id == trackId) {
          return track.copyWith(likeCount: track.likeCount + 1);
        }
        return track;
      }).toList();

      state = state.copyWith(tracks: updatedTracks);
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlikeTrack(String trackId) async {
    try {
      await _repository.unlikeTrack(trackId);

      // Update local state
      final updatedTracks = state.tracks.map((track) {
        if (track.id == trackId) {
          return track.copyWith(likeCount: track.likeCount - 1);
        }
        return track;
      }).toList();

      state = state.copyWith(tracks: updatedTracks);
    } catch (e) {
      // Handle error
      state = state.copyWith(error: e.toString());
    }
  }
}

// Tracks Controller Provider
final tracksControllerProvider =
    StateNotifierProvider<TracksController, TracksState>((ref) {
  final repository = ref.watch(tracksRepositoryProvider);
  return TracksController(repository);
});
