import 'package:dio/dio.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';

class TracksRepository {
  final Dio _dio;

  TracksRepository(this._dio);

  Future<List<Track>> getTracks({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
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

  Future<Track> getTrackById(String id) async {
    try {
      final response = await _dio.get('/tracks/$id/');
      return Track.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Failed to load track: ${e.message}');
    }
  }

  Future<void> likeTrack(String trackId) async {
    try {
      await _dio.post('/tracks/$trackId/like/');
    } on DioException catch (e) {
      throw Exception('Failed to like track: ${e.message}');
    }
  }

  Future<void> unlikeTrack(String trackId) async {
    try {
      await _dio.delete('/tracks/$trackId/like/');
    } on DioException catch (e) {
      throw Exception('Failed to unlike track: ${e.message}');
    }
  }
}
