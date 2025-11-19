import 'package:dio/dio.dart';
import '../domain/user_profile.dart';
import '../domain/feed_item.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profiles/$userId',
      );
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load user profile: ${e.message}');
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

  Future<List<UserSummary>> getFollowers(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/$userId/followers',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserSummary.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load followers: ${e.message}');
    }
  }

  Future<List<UserSummary>> getFollowing(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/profiles/$userId/following',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserSummary.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load following: ${e.message}');
    }
  }

  Future<List<FeedItem>> getFollowingFeed({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/feed/following',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => FeedItem.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load following feed: ${e.message}');
    }
  }
}
