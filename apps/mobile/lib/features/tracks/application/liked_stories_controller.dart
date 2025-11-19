import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/story/domain/story.dart';

class LikedStoriesState {
  final List<Story> stories;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  LikedStoriesState({
    this.stories = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  LikedStoriesState copyWith({
    List<Story>? stories,
    bool? isLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return LikedStoriesState(
      stories: stories ?? this.stories,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class LikedStoriesController extends StateNotifier<LikedStoriesState> {
  final TracksRepository _repository;
  static const int _pageSize = 20;

  LikedStoriesController(this._repository) : super(LikedStoriesState()) {
    loadStories();
  }

  Future<void> loadStories({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = LikedStoriesState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final offset = refresh ? 0 : state.stories.length;
      final newStories = await _repository.getLikedStories(
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = LikedStoriesState(
          stories: newStories,
          isLoading: false,
          hasMore: newStories.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          stories: [...state.stories, ...newStories],
          isLoading: false,
          hasMore: newStories.length >= _pageSize,
        );
      }
    } catch (e) {
      String errorMessage = 'ストーリーの読み込みに失敗しました';
      if (e.toString().contains('timeout')) {
        errorMessage = 'サーバーへの接続がタイムアウトしました\nネットワーク接続を確認してください';
      } else if (e.toString().contains('Failed to load liked stories')) {
        errorMessage = 'いいねしたストーリーの取得中にエラーが発生しました';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadStories();
  }

  Future<void> refresh() async {
    await loadStories(refresh: true);
  }

  Future<void> unlikeStory(String storyId) async {
    try {
      await _repository.unlikeStory(storyId);
      // Remove from list immediately as it's no longer liked
      final updatedStories = state.stories.where((s) => s.id != storyId).toList();
      state = state.copyWith(stories: updatedStories);
    } catch (e) {
       // Handle error
    }
  }
}

final likedStoriesControllerProvider =
    StateNotifierProvider<LikedStoriesController, LikedStoriesState>((ref) {
  final repository = ref.watch(tracksRepositoryProvider);
  return LikedStoriesController(repository);
});
