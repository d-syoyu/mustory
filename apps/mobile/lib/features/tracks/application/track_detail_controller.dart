import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';

// Track Detail State
class TrackDetailState {
  final TrackDetail? trackDetail;
  final bool isLoading;
  final String? error;

  TrackDetailState({
    this.trackDetail,
    this.isLoading = false,
    this.error,
  });

  TrackDetailState copyWith({
    TrackDetail? trackDetail,
    bool? isLoading,
    String? error,
  }) {
    return TrackDetailState(
      trackDetail: trackDetail ?? this.trackDetail,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Track Detail Controller
class TrackDetailController extends StateNotifier<TrackDetailState> {
  final TracksRepository _repository;
  final String trackId;

  TrackDetailController(this._repository, this.trackId)
      : super(TrackDetailState(isLoading: true)) {
    loadTrackDetail();
  }

  Future<void> loadTrackDetail() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await _repository.getTrackDetail(trackId);
      state = TrackDetailState(
        trackDetail: detail,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'トラック詳細の読み込みに失敗しました',
      );
    }
  }

  Future<void> refresh() async {
    await loadTrackDetail();
  }

  Future<void> likeTrack() async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      await _repository.likeTrack(trackId);

      // Update local state
      final updatedTrack = currentDetail.track.copyWith(
        likeCount: currentDetail.track.likeCount + 1,
        isLiked: true,
      );
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: updatedTrack),
      );
    } catch (e) {
      state = state.copyWith(error: 'いいねに失敗しました');
    }
  }

  Future<void> unlikeTrack() async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      await _repository.unlikeTrack(trackId);

      // Update local state
      final updatedTrack = currentDetail.track.copyWith(
        likeCount: currentDetail.track.likeCount - 1,
        isLiked: false,
      );
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: updatedTrack),
      );
    } catch (e) {
      state = state.copyWith(error: 'いいね解除に失敗しました');
    }
  }

  Future<void> addComment(String body, {String? parentCommentId}) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      await _repository.createTrackComment(
        trackId,
        body,
        parentCommentId: parentCommentId,
      );

      // Refresh to get updated comments with proper reply counts
      await loadTrackDetail();
    } catch (e) {
      state = state.copyWith(error: 'コメントの投稿に失敗しました');
    }
  }

  Future<void> addStoryComment(
    String storyId,
    String body, {
    String? parentCommentId,
  }) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      await _repository.createStoryComment(
        storyId,
        body,
        parentCommentId: parentCommentId,
      );

      // Refresh to get updated comments with proper reply counts
      await loadTrackDetail();
    } catch (e) {
      state = state.copyWith(error: 'ストーリーコメントの投稿に失敗しました');
    }
  }
}

// Track Detail Controller Provider
final trackDetailControllerProvider = StateNotifierProvider.family<
    TrackDetailController, TrackDetailState, String>((ref, trackId) {
  final repository = ref.watch(tracksRepositoryProvider);
  return TrackDetailController(repository, trackId);
});
