import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/domain/comment.dart';
import '../../../../core/analytics/analytics_service.dart';

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
  final AnalyticsService _analyticsService;
  final String trackId;

  TrackDetailController(this._repository, this._analyticsService, this.trackId)
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

    // Optimistically update UI
    final updatedTrack = currentDetail.track.copyWith(
      likeCount: currentDetail.track.likeCount + 1,
      isLiked: true,
    );
    state = state.copyWith(
      trackDetail: currentDetail.copyWith(track: updatedTrack),
    );

    try {
      await _repository.likeTrack(trackId);
      // Refresh to ensure consistency with server
      await loadTrackDetail();
    } catch (e) {
      // Revert on error
      final revertedTrack = currentDetail.track.copyWith(
        likeCount: currentDetail.track.likeCount,
        isLiked: false,
      );
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: revertedTrack),
        error: 'いいねに失敗しました',
      );
    }
  }

  Future<void> unlikeTrack() async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    // Optimistically update UI
    final currentLikeCount = currentDetail.track.likeCount;
    final updatedTrack = currentDetail.track.copyWith(
      likeCount: currentLikeCount > 0 ? currentLikeCount - 1 : 0,
      isLiked: false,
    );
    state = state.copyWith(
      trackDetail: currentDetail.copyWith(track: updatedTrack),
    );

    try {
      await _repository.unlikeTrack(trackId);
      // Refresh to ensure consistency with server
      await loadTrackDetail();
    } catch (e) {
      // Revert on error
      final revertedTrack = currentDetail.track.copyWith(
        likeCount: currentDetail.track.likeCount,
        isLiked: true,
      );
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: revertedTrack),
        error: 'いいね解除に失敗しました',
      );
    }
  }

  Future<void> likeStory(String storyId) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null || currentDetail.track.story == null) return;

    // Optimistically update UI
    final currentStory = currentDetail.track.story!;
    final updatedStory = Map<String, dynamic>.from(currentStory);
    updatedStory['like_count'] = (currentStory['like_count'] as int? ?? 0) + 1;
    updatedStory['is_liked'] = true;

    final updatedTrack = currentDetail.track.copyWith(story: updatedStory);
    state = state.copyWith(
      trackDetail: currentDetail.copyWith(track: updatedTrack),
    );

    try {
      await _repository.likeStory(storyId);
      // Refresh to ensure consistency with server
      await loadTrackDetail();
    } catch (e) {
      // Revert on error
      final revertedStory = Map<String, dynamic>.from(currentStory);
      final revertedTrack = currentDetail.track.copyWith(story: revertedStory);
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: revertedTrack),
        error: 'ストーリーのいいねに失敗しました',
      );
    }
  }

  Future<void> unlikeStory(String storyId) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null || currentDetail.track.story == null) return;

    // Optimistically update UI
    final currentStory = currentDetail.track.story!;
    final updatedStory = Map<String, dynamic>.from(currentStory);
    final currentLikeCount = currentStory['like_count'] as int? ?? 0;
    updatedStory['like_count'] = currentLikeCount > 0 ? currentLikeCount - 1 : 0;
    updatedStory['is_liked'] = false;

    final updatedTrack = currentDetail.track.copyWith(story: updatedStory);
    state = state.copyWith(
      trackDetail: currentDetail.copyWith(track: updatedTrack),
    );

    try {
      await _repository.unlikeStory(storyId);
      // Refresh to ensure consistency with server
      await loadTrackDetail();
    } catch (e) {
      // Revert on error
      final revertedStory = Map<String, dynamic>.from(currentStory);
      final revertedTrack = currentDetail.track.copyWith(story: revertedStory);
      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: revertedTrack),
        error: 'ストーリーのいいね解除に失敗しました',
      );
    }
  }

  Future<void> addComment(String body, {String? parentCommentId}) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      final comment = await _repository.createTrackComment(
        trackId,
        body,
        parentCommentId: parentCommentId,
      );

      // Log analytics
      await _analyticsService.logCommentPosted(
        targetType: 'track',
        targetId: trackId,
        commentId: comment.id,
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
      final comment = await _repository.createStoryComment(
        storyId,
        body,
        parentCommentId: parentCommentId,
      );

      // Log analytics
      await _analyticsService.logCommentPosted(
        targetType: 'story',
        targetId: storyId,
        commentId: comment.id,
      );

      // Refresh to get updated comments with proper reply counts
      await loadTrackDetail();
    } catch (e) {
      state = state.copyWith(error: 'ストーリーコメントの投稿に失敗しました');
    }
  }

  Future<void> updateTrack({
    required String title,
    required String artistName,
    String? storyLead,
    String? storyBody,
  }) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      final updatedTrack = await _repository.updateTrack(
        trackId,
        title: title,
        artistName: artistName,
        storyLead: storyLead,
        storyBody: storyBody,
      );

      state = state.copyWith(
        trackDetail: currentDetail.copyWith(track: updatedTrack),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'トラックの更新に失敗しました');
      rethrow;
    }
  }

  Future<void> setCommentLike({
    required String commentId,
    required bool isStoryComment,
    required bool like,
  }) async {
    final currentDetail = state.trackDetail;
    if (currentDetail == null) return;

    try {
      if (like) {
        await _repository.likeComment(commentId);
      } else {
        await _repository.unlikeComment(commentId);
      }

      List<Comment> updateComments(
        List<Comment> comments,
      ) {
        return comments
            .map(
              (c) => c.id == commentId
                  ? c.copyWith(
                      isLiked: like,
                      likeCount: like
                          ? c.likeCount + 1
                          : (c.likeCount - 1 < 0 ? 0 : c.likeCount - 1),
                    )
                  : c,
            )
            .toList();
      }

      state = state.copyWith(
        trackDetail: currentDetail.copyWith(
          trackComments: isStoryComment
              ? currentDetail.trackComments
              : updateComments(currentDetail.trackComments),
          storyComments: isStoryComment
              ? updateComments(currentDetail.storyComments)
              : currentDetail.storyComments,
        ),
      );
    } catch (e) {
      state = state.copyWith(error: 'コメントのいいね操作に失敗しました');
      rethrow;
    }
  }
}

// Track Detail Controller Provider
final trackDetailControllerProvider = StateNotifierProvider.family<
    TrackDetailController, TrackDetailState, String>((ref, trackId) {
  final repository = ref.watch(tracksRepositoryProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return TrackDetailController(repository, analyticsService, trackId);
});
