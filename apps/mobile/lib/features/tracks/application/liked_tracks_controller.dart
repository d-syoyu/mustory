import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_state.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';

class LikedTracksController extends StateNotifier<TracksState> {
  final TracksRepository _repository;
  static const int _pageSize = 20;

  LikedTracksController(this._repository) : super(TracksState()) {
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
      final newTracks = await _repository.getLikedTracks(
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
      } else if (e.toString().contains('Failed to load liked tracks')) {
        errorMessage = 'いいねした曲の取得中にエラーが発生しました';
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

  Future<void> unlikeTrack(String trackId) async {
    try {
      await _repository.unlikeTrack(trackId);
      // Remove from list immediately as it's no longer liked
      final updatedTracks = state.tracks.where((t) => t.id != trackId).toList();
      state = state.copyWith(tracks: updatedTracks);
    } catch (e) {
       // Handle error
    }
  }
}

final likedTracksControllerProvider =
    StateNotifierProvider<LikedTracksController, TracksState>((ref) {
  final repository = ref.watch(tracksRepositoryProvider);
  return LikedTracksController(repository);
});
