import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_state.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';

class MyTracksController extends StateNotifier<TracksState> {
  final TracksRepository _repository;
  static const int _pageSize = 20;

  MyTracksController(this._repository) : super(TracksState()) {
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
      final newTracks = await _repository.getMyTracks(
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
      } else if (e.toString().contains('Failed to load my tracks')) {
        errorMessage = 'マイトラックの取得中にエラーが発生しました';
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

  Future<void> deleteTrack(String trackId) async {
    try {
      await _repository.deleteTrack(trackId);
      final updatedTracks = state.tracks.where((t) => t.id != trackId).toList();
      state = state.copyWith(tracks: updatedTracks);
    } catch (e) {
      // Handle error if needed, maybe show a snackbar in UI
      // For now just keep state as is or set error
    }
  }

  Future<void> updateTrackInList(String trackId, {
    required String title,
    required String artistName,
    String? storyLead,
    String? storyBody,
  }) async {
     final updatedTracks = state.tracks.map((track) {
        if (track.id == trackId) {
          return track.copyWith(
            title: title,
            artistName: artistName,
            // Note: Track model might need updating if we want to reflect story changes immediately in list
            // providing story is part of the list model.
            // For now we update what we can.
          );
        }
        return track;
      }).toList();
      state = state.copyWith(tracks: updatedTracks);
  }
}

final myTracksControllerProvider =
    StateNotifierProvider<MyTracksController, TracksState>((ref) {
  final repository = ref.watch(tracksRepositoryProvider);
  return MyTracksController(repository);
});
