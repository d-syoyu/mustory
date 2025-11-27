import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/user_profile.dart';
import '../domain/feed_item.dart';
import '../../tracks/domain/track.dart';
import '../../story/domain/story.dart';
import '../../../core/network/api_cache.dart';
import 'dart:io';

class ProfileRepository {
  final Dio _dio;
  final ApiCache _cache = ApiCache();

  ProfileRepository(this._dio);

  Future<UserProfile> getUserProfile(String userId, {bool forceRefresh = false}) async {
    final cacheKey = 'profile_$userId';

    if (!forceRefresh) {
      final cached = _cache.get<UserProfile>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profiles/$userId',
      );
      final profile = UserProfile.fromJson(response.data as Map<String, dynamic>);

      // Cache profile for 2 minutes
      _cache.set(cacheKey, profile, duration: const Duration(minutes: 2));
      return profile;
    } on DioException catch (e) {
      throw Exception('Failed to load user profile: ${e.message}');
    }
  }

  /// Invalidate profile cache
  void invalidateProfileCache(String userId) {
    _cache.invalidate('profile_$userId');
  }

  Future<UserProfile> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? location,
    String? linkUrl,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (location != null) data['location'] = location;
      if (linkUrl != null) data['link_url'] = linkUrl;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      final response = await _dio.put<Map<String, dynamic>>(
        '/me/profile',
        data: data,
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> followUser(String userId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/follows/$userId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to follow user: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> unfollowUser(String userId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/follows/$userId',
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to unfollow user: ${e.message}');
    }
  }

  Future<UserPage> getFollowers(
    String userId, {
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profiles/$userId/followers',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final data = response.data ?? {};
      final items = (data['items'] as List? ?? [])
          .map((json) => UserSummary.fromJson(json as Map<String, dynamic>))
          .toList();
      final nextCursor = data['next_cursor'] as String?;
      return UserPage(items: items, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw Exception('Failed to load followers: ${e.message}');
    }
  }

  Future<UserPage> getFollowing(
    String userId, {
    int limit = 50,
    String? cursor,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profiles/$userId/following',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final data = response.data ?? {};
      final items = (data['items'] as List? ?? [])
          .map((json) => UserSummary.fromJson(json as Map<String, dynamic>))
          .toList();
      final nextCursor = data['next_cursor'] as String?;
      return UserPage(items: items, nextCursor: nextCursor);
    } on DioException catch (e) {
      throw Exception('Failed to load following: ${e.message}');
    }
  }

  Future<FollowFeedPage> getFollowingFeed({
    int limit = 50,
    String? cursor,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'following_feed_${limit}_${cursor ?? 'initial'}';

    // Only cache the initial page (no cursor)
    if (!forceRefresh && cursor == null) {
      final cached = _cache.get<FollowFeedPage>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/feed/following',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );

      final data = response.data ?? {};
      final items = (data['items'] as List? ?? [])
          .map((json) => FeedItem.fromJson(json as Map<String, dynamic>))
          .toList();
      final nextCursor = data['next_cursor'] as String?;
      final feedPage = FollowFeedPage(items: items, nextCursor: nextCursor);

      // Cache initial page for 1 minute
      if (cursor == null) {
        _cache.set(cacheKey, feedPage, duration: const Duration(minutes: 1));
      }
      return feedPage;
    } on DioException catch (e) {
      throw Exception('Failed to load following feed: ${e.message}');
    }
  }

  Future<String> uploadAvatar(XFile file) async {
    final fileName = file.name;
    final contentType = _detectContentType(fileName);
    try {
      // 1) Get presign
      final presignResp = await _dio.post<Map<String, dynamic>>(
        '/uploads/avatar/presign',
        data: {
          'file_name': fileName,
          'content_type': contentType,
        },
      );
      final presign = presignResp.data ?? {};
      final uploadUrl = presign['upload_url'] as String?;
      final publicUrl = presign['public_url'] as String?;
      if (uploadUrl == null || publicUrl == null) {
        throw Exception('Invalid presign response');
      }

      // 2) Upload binary to storage
      final bytes = await file.readAsBytes();
      final uploadDio = Dio();
      await uploadDio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: contentType,
            HttpHeaders.contentLengthHeader: bytes.length,
          },
        ),
      );

      return publicUrl;
    } on DioException catch (e) {
      throw Exception('Failed to upload avatar: ${e.message}');
    }
  }

  String _detectContentType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<List<Track>> getUserTracks(
    String userId, {
    int limit = 50,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'user_tracks_${userId}_${limit}_$offset';

    if (!forceRefresh && offset == 0) {
      final cached = _cache.get<List<Track>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/$userId/tracks',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        final tracks = (response.data as List)
            .map((json) => Track.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache first page for 2 minutes
        if (offset == 0) {
          _cache.set(cacheKey, tracks, duration: const Duration(minutes: 2));
        }
        return tracks;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load user tracks: ${e.message}');
    }
  }

  Future<List<Story>> getUserStories(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/$userId/stories',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Story.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load user stories: ${e.message}');
    }
  }

  Future<List<Track>> getUserLikedTracks(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/$userId/liked-tracks',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Track.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load user liked tracks: ${e.message}');
    }
  }

  Future<List<UserSummary>> searchUsers({
    required String query,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'search_users_${query}_$limit';

    if (!forceRefresh) {
      final cached = _cache.get<List<UserSummary>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/search',
        queryParameters: {
          'q': query,
          'limit': limit,
        },
      );

      if (response.data is List) {
        final users = (response.data as List)
            .map((json) => UserSummary.fromJson(json as Map<String, dynamic>))
            .toList();

        // Cache search results for 2 minutes
        _cache.set(cacheKey, users, duration: const Duration(minutes: 2));
        return users;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to search users: ${e.message}');
    }
  }

  /// Clear all profile-related caches
  void clearAllCaches() {
    _cache.invalidatePattern('profile_');
    _cache.invalidatePattern('user_tracks_');
    _cache.invalidatePattern('following_feed_');
    _cache.invalidatePattern('search_users_');
  }
}
