import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/track.dart';
import '../data/track_detail_repository.dart';

final trackDetailRepositoryProvider = Provider<TrackDetailRepository>(
  (ref) => TrackDetailRepository(),
);

final trackDetailControllerProvider = AsyncNotifierProviderFamily<
    TrackDetailController, TrackDetailState, String>(
  TrackDetailController.new,
);

class TrackDetailController
    extends FamilyAsyncNotifier<TrackDetailState, String> {
  late final TrackDetailRepository _repository;
  late String _trackId;

  @override
  FutureOr<TrackDetailState> build(String arg) async {
    _repository = ref.watch(trackDetailRepositoryProvider);
    _trackId = arg;
    return _load();
  }

  Future<TrackDetailState> _load() async {
    final track = await _repository.fetchTrack(_trackId);
    final trackComments = await _repository.fetchTrackComments(_trackId);
    final storyComments = track.story == null
        ? <Comment>[]
        : await _repository.fetchStoryComments(track.story!.id);

    return TrackDetailState(
      track: track,
      trackComments: trackComments,
      storyComments: storyComments,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> postComment({
    required CommentTargetType targetType,
    required String body,
  }) async {
    final current = state.asData?.value;
    if (current == null || body.trim().isEmpty) {
      return;
    }

    final targetId = targetType == CommentTargetType.track
        ? current.track.id
        : current.track.story?.id;

    if (targetId == null) {
      return;
    }

    await _repository.postComment(
      targetType: targetType,
      targetId: targetId,
      body: body,
    );
    await refresh();
  }
}

class TrackDetailState {
  const TrackDetailState({
    required this.track,
    required this.trackComments,
    required this.storyComments,
  });

  final Track track;
  final List<Comment> trackComments;
  final List<Comment> storyComments;
}
