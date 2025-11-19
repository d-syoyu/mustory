import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/network/api_client.dart';
import 'package:mustory_mobile/features/profile/data/profile_repository.dart';
import 'package:mustory_mobile/features/profile/domain/user_profile.dart';
import 'package:mustory_mobile/features/profile/domain/feed_item.dart';

// Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

// Profile State
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Profile Controller
class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final String userId;

  ProfileController(this._repository, this.userId) : super(ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _repository.getUserProfile(userId);
      state = ProfileState(profile: profile, isLoading: false);
    } catch (e) {
      state = ProfileState(
        isLoading: false,
        error: 'プロフィールの読み込みに失敗しました: $e',
      );
    }
  }

  Future<void> toggleFollow() async {
    if (state.profile == null) return;

    final currentProfile = state.profile!;
    final wasFollowing = currentProfile.isFollowedByMe;

    // Optimistic update
    state = state.copyWith(
      profile: currentProfile.copyWith(
        isFollowedByMe: !wasFollowing,
        followerCount: wasFollowing
            ? currentProfile.followerCount - 1
            : currentProfile.followerCount + 1,
      ),
    );

    try {
      final response = wasFollowing
          ? await _repository.unfollowUser(userId)
          : await _repository.followUser(userId);

      // Update with actual follower count from server
      final followerCount = response['follower_count'] as int? ??
          (wasFollowing ? currentProfile.followerCount - 1 : currentProfile.followerCount + 1);

      state = state.copyWith(
        profile: state.profile?.copyWith(
          followerCount: followerCount,
        ),
      );
    } catch (e) {
      // Revert optimistic update on error
      state = state.copyWith(
        profile: currentProfile,
        error: 'フォロー操作に失敗しました: $e',
      );
    }
  }
}

// Profile Provider Factory
final profileControllerProvider = StateNotifierProvider.family<
    ProfileController, ProfileState, String>(
  (ref, userId) {
    final repository = ref.watch(profileRepositoryProvider);
    return ProfileController(repository, userId);
  },
);

// Followers List State
class FollowersState {
  final List<UserSummary> users;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  FollowersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  FollowersState copyWith({
    List<UserSummary>? users,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return FollowersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Followers Controller
class FollowersController extends StateNotifier<FollowersState> {
  final ProfileRepository _repository;
  final String userId;
  static const int _pageSize = 50;

  FollowersController(this._repository, this.userId) : super(FollowersState()) {
    loadFollowers();
  }

  Future<void> loadFollowers({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = FollowersState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final offset = refresh ? 0 : state.users.length;
      final newUsers = await _repository.getFollowers(
        userId,
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = FollowersState(
          users: newUsers,
          isLoading: false,
          hasMore: newUsers.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          users: [...state.users, ...newUsers],
          isLoading: false,
          hasMore: newUsers.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'フォロワーの読み込みに失敗しました: $e',
      );
    }
  }
}

final followersControllerProvider = StateNotifierProvider.family<
    FollowersController, FollowersState, String>(
  (ref, userId) {
    final repository = ref.watch(profileRepositoryProvider);
    return FollowersController(repository, userId);
  },
);

// Following List State and Controller
class FollowingController extends StateNotifier<FollowersState> {
  final ProfileRepository _repository;
  final String userId;
  static const int _pageSize = 50;

  FollowingController(this._repository, this.userId) : super(FollowersState()) {
    loadFollowing();
  }

  Future<void> loadFollowing({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = FollowersState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final offset = refresh ? 0 : state.users.length;
      final newUsers = await _repository.getFollowing(
        userId,
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = FollowersState(
          users: newUsers,
          isLoading: false,
          hasMore: newUsers.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          users: [...state.users, ...newUsers],
          isLoading: false,
          hasMore: newUsers.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'フォロー中の読み込みに失敗しました: $e',
      );
    }
  }
}

final followingControllerProvider = StateNotifierProvider.family<
    FollowingController, FollowersState, String>(
  (ref, userId) {
    final repository = ref.watch(profileRepositoryProvider);
    return FollowingController(repository, userId);
  },
);

// Following Feed State
class FollowingFeedState {
  final List<FeedItem> items;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  FollowingFeedState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  FollowingFeedState copyWith({
    List<FeedItem>? items,
    bool? isLoading,
    String? error,
    bool? hasMore,
  }) {
    return FollowingFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Following Feed Controller
class FollowingFeedController extends StateNotifier<FollowingFeedState> {
  final ProfileRepository _repository;
  static const int _pageSize = 50;

  FollowingFeedController(this._repository) : super(FollowingFeedState()) {
    loadFeed();
  }

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = FollowingFeedState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final offset = refresh ? 0 : state.items.length;
      final newItems = await _repository.getFollowingFeed(
        limit: _pageSize,
        offset: offset,
      );

      if (refresh) {
        state = FollowingFeedState(
          items: newItems,
          isLoading: false,
          hasMore: newItems.length >= _pageSize,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...newItems],
          isLoading: false,
          hasMore: newItems.length >= _pageSize,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'フィードの読み込みに失敗しました: $e',
      );
    }
  }
}

final followingFeedControllerProvider = StateNotifierProvider<
    FollowingFeedController, FollowingFeedState>(
  (ref) {
    final repository = ref.watch(profileRepositoryProvider);
    return FollowingFeedController(repository);
  },
);
