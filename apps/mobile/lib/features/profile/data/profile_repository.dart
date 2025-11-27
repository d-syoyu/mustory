import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/user_profile.dart';
import '../domain/feed_item.dart';
import 'dart:io';

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
  }) async {
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
      return FollowFeedPage(items: items, nextCursor: nextCursor);
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
}
