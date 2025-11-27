import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/network/api_client.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_state.dart';

// Repository Provider
final tracksRepositoryProvider = Provider<TracksRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TracksRepository(dio);
});

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
      state = state.copyWith(isLoading: true, clearError: true);
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
      String errorMessage = 'トラックの読み込みに失敗しました';
      if (e.toString().contains('timeout')) {
        errorMessage = 'サーバーへの接続がタイムアウトしました\nネットワーク接続を確認してください';
      } else if (e.toString().contains('Failed to load tracks')) {
        errorMessage = 'トラックの取得中にエラーが発生しました';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
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
    // Find the original track before update
    final originalTrack = state.tracks.firstWhere(
      (track) => track.id == trackId,
      orElse: () => state.tracks.first,
    );

    // Optimistically update UI
    final updatedTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        return track.copyWith(
          likeCount: track.likeCount + 1,
          isLiked: true,
        );
      }
      return track;
    }).toList();

    state = state.copyWith(tracks: updatedTracks);

    try {
      await _repository.likeTrack(trackId);
    } catch (e) {
      // Revert on error
      final revertedTracks = state.tracks.map((track) {
        if (track.id == trackId) {
          return track.copyWith(
            likeCount: originalTrack.likeCount,
            isLiked: false,
          );
        }
        return track;
      }).toList();

      state = state.copyWith(
        tracks: revertedTracks,
        error: 'いいねに失敗しました',
      );
    }
  }

  Future<void> unlikeTrack(String trackId) async {
    // Find the original track before update
    final originalTrack = state.tracks.firstWhere(
      (track) => track.id == trackId,
      orElse: () => state.tracks.first,
    );

    // Optimistically update UI
    final updatedTracks = state.tracks.map((track) {
      if (track.id == trackId) {
        final currentLikeCount = track.likeCount;
        return track.copyWith(
          likeCount: currentLikeCount > 0 ? currentLikeCount - 1 : 0,
          isLiked: false,
        );
      }
      return track;
    }).toList();

    state = state.copyWith(tracks: updatedTracks);

    try {
      await _repository.unlikeTrack(trackId);
    } catch (e) {
      // Revert on error
      final revertedTracks = state.tracks.map((track) {
        if (track.id == trackId) {
          return track.copyWith(
            likeCount: originalTrack.likeCount,
            isLiked: true,
          );
        }
        return track;
      }).toList();

      state = state.copyWith(
        tracks: revertedTracks,
        error: 'いいね解除に失敗しました',
      );
    }
  }
}

// Tracks Controller Provider
final tracksControllerProvider =
    StateNotifierProvider<TracksController, TracksState>((ref) {
  final repository = ref.watch(tracksRepositoryProvider);
  return TracksController(repository);
});
