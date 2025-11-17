import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mustory_mobile/features/upload/application/upload_controller.dart';
import 'package:mustory_mobile/features/upload/data/upload_repository.dart';
import 'package:mustory_mobile/features/upload/domain/upload_models.dart';

void main() {
  group('UploadController', () {
    late _FakeUploadRepository repository;
    late UploadController controller;

    setUp(() {
      repository = _FakeUploadRepository();
      controller = UploadController(
        repository,
        pollInterval: const Duration(milliseconds: 1),
      );
    });

    test('happy path uploads files and completes', () async {
      await controller.uploadTrack(
        title: 'Demo Song',
        artistName: 'Tester',
        audioFile: File('audio.mp3'),
        artworkFile: File('art.png'),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      final completed = controller.state.maybeMap(
        completed: (state) => state.trackId,
        orElse: () => null,
      );
      expect(completed, 'track-123');
      expect(repository.uploadedFiles.length, 2);
      expect(repository.completeCalls, 1);
    });
  });
}

class _FakeUploadRepository extends UploadRepository {
  _FakeUploadRepository() : super(Dio());

  final List<String> uploadedFiles = [];
  int completeCalls = 0;

  @override
  Future<TrackUploadInitResponse> initializeUpload(
    TrackUploadInitRequest request,
  ) async {
    return const TrackUploadInitResponse(
      trackId: 'track-123',
      audioUploadUrl: 'https://upload/audio',
      artworkUploadUrl: 'https://upload/art',
    );
  }

  @override
  Future<void> uploadFileToS3({
    required String presignedUrl,
    required File file,
    required void Function(double p1) onProgress,
  }) async {
    uploadedFiles.add(file.path);
    onProgress(1.0);
  }

  @override
  Future<void> completeUpload(String trackId) async {
    completeCalls += 1;
  }

  @override
  Future<TrackProcessingStatus> getProcessingStatus(String trackId) async {
    return const TrackProcessingStatus(
      trackId: 'track-123',
      status: 'completed',
      progress: 100,
    );
  }

  @override
  String getFileExtension(String filePath) {
    return filePath.endsWith('.png') ? 'png' : 'mp3';
  }

  @override
  Future<int> getFileSize(File file) async {
    return 1024;
  }
}
