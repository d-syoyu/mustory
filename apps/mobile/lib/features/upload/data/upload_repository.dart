import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../domain/upload_models.dart';

class UploadRepository {
  final Dio _dio;

  UploadRepository(this._dio);

  /// Initialize track upload and get presigned URLs
  Future<TrackUploadInitResponse> initializeUpload(
    TrackUploadInitRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/tracks/upload/init',
      data: request.toJson(),
    );

    return TrackUploadInitResponse.fromJson(response.data!);
  }

  /// Upload file to S3 using presigned PUT URL
  Future<void> uploadFileToS3({
    required String presignedUrl,
    required File file,
    required void Function(double) onProgress,
  }) async {
    print('=== S3 Upload Debug ===');
    print('URL: $presignedUrl');

    final fileBytes = await file.readAsBytes();
    print('File size: ${fileBytes.length} bytes');

    print('Sending PUT request to S3...');

    // Report initial progress
    onProgress(0.0);

    // Send PUT request
    final response = await http.put(
      Uri.parse(presignedUrl),
      body: fileBytes,
      headers: {
        'Content-Type': _getContentType(file.path),
      },
    );

    print('S3 Response status: ${response.statusCode}');
    print('S3 Response body: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload failed: ${response.statusCode} ${response.body}');
    }

    print('S3 Upload successful!');

    // Report completion
    onProgress(1.0);
  }

  String _getContentType(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.m4a':
        return 'audio/mp4';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  /// Mark upload as complete and trigger processing
  Future<void> completeUpload(String trackId) async {
    await _dio.post<Map<String, dynamic>>(
      '/tracks/upload/complete',
      data: {'track_id': trackId},
    );
  }

  /// Get processing status
  Future<TrackProcessingStatus> getProcessingStatus(String trackId) async {
    final response = await _dio.get<Map<String, dynamic>>('/tracks/upload/status/$trackId');
    return TrackProcessingStatus.fromJson(response.data!);
  }

  /// Get file extension from file path
  String getFileExtension(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return ext.startsWith('.') ? ext.substring(1) : ext;
  }

  /// Get file size
  Future<int> getFileSize(File file) async {
    return await file.length();
  }
}
