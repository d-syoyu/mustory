import 'package:dio/dio.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/features/tracks/domain/track_detail.dart';
import 'package:mustory_mobile/features/tracks/domain/comment.dart';

class TracksRepository {
  final Dio _dio;

  TracksRepository(this._dio);

  Future<List<Track>> getTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/tracks/',
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
      throw Exception('Failed to load tracks: ${e.message}');
    }
  }

  Future<TrackDetail> getTrackDetail(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tracks/$id');
      return TrackDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load track detail: ${e.message}');
    }
  }

  Future<List<Comment>> getTrackComments(String trackId) async {
    try {
      final response = await _dio.get<List<dynamic>>('/tracks/$trackId/comments');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => Comment.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load comments: ${e.message}');
    }
  }

  Future<Comment> createTrackComment(
    String trackId,
    String body, {
    String? parentCommentId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tracks/$trackId/comments',
        data: {
          'body': body,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        },
      );
      return Comment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create comment: ${e.message}');
    }
  }

  Future<Comment> createStoryComment(
    String storyId,
    String body, {
    String? parentCommentId,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/stories/$storyId/comments',
        data: {
          'body': body,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId,
        },
      );
      return Comment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to create story comment: ${e.message}');
    }
  }

  Future<void> likeTrack(String trackId) async {
    try {
      await _dio.post<void>('/tracks/$trackId/like');
    } on DioException catch (e) {
      throw Exception('Failed to like track: ${e.message}');
    }
  }

  Future<void> unlikeTrack(String trackId) async {
    try {
      await _dio.delete<void>('/tracks/$trackId/like');
    } on DioException catch (e) {
      throw Exception('Failed to unlike track: ${e.message}');
    }
  }
}
