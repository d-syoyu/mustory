import 'dart:io';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/upload_repository.dart';
import '../domain/upload_models.dart';

final uploadRepositoryProvider = Provider<UploadRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return UploadRepository(dio);
});

final uploadControllerProvider =
    StateNotifierProvider<UploadController, UploadState>((ref) {
  final repository = ref.watch(uploadRepositoryProvider);
  return UploadController(repository);
});

class UploadController extends StateNotifier<UploadState> {
  final UploadRepository _repository;
  final Duration _pollInterval;

  UploadController(
    this._repository, {
    Duration pollInterval = const Duration(seconds: 2),
  })  : _pollInterval = pollInterval,
        super(const UploadState.idle());

  /// Upload a track with audio file and optional artwork
  Future<void> uploadTrack({
    required String title,
    required String artistName,
    required File audioFile,
    File? artworkFile,
  }) async {
    try {
      // Step 1: Get file information
      state = const UploadState.initializing();

      final audioExtension = _repository.getFileExtension(audioFile.path);
      final audioSize = await _repository.getFileSize(audioFile);

      String? artworkExtension;
      if (artworkFile != null) {
        artworkExtension = _repository.getFileExtension(artworkFile.path);
      }

      // Step 2: Initialize upload - get presigned URLs
      state = const UploadState.uploading(
        progress: 0.0,
        message: 'Initializing upload...',
      );

      final initRequest = TrackUploadInitRequest(
        title: title,
        artistName: artistName,
        fileExtension: audioExtension,
        fileSize: audioSize,
        artworkExtension: artworkExtension,
      );

      final initResponse = await _repository.initializeUpload(initRequest);

      // Step 3: Upload audio file to S3
      state = const UploadState.uploading(
        progress: 0.1,
        message: 'Uploading audio file...',
      );

      print('=== Starting S3 upload ===');
      print('Presigned URL: ${initResponse.audioUploadUrl}');

      await _repository.uploadFileToS3(
        presignedUrl: initResponse.audioUploadUrl,
        file: audioFile,
        onProgress: (progress) {
          // Map progress from 0.1 to 0.6 (50% of total)
          final mappedProgress = 0.1 + (progress * 0.5);
          state = UploadState.uploading(
            progress: mappedProgress,
            message: 'Uploading audio: ${(progress * 100).toInt()}%',
          );
        },
      );

      print('=== S3 upload completed ===');

      // Step 4: Upload artwork if provided
      if (artworkFile != null && initResponse.artworkUploadUrl != null) {
        state = const UploadState.uploading(
          progress: 0.6,
          message: 'Uploading artwork...',
        );

        await _repository.uploadFileToS3(
          presignedUrl: initResponse.artworkUploadUrl!,
          file: artworkFile,
          onProgress: (progress) {
            // Map progress from 0.6 to 0.8 (20% of total)
            final mappedProgress = 0.6 + (progress * 0.2);
            state = UploadState.uploading(
              progress: mappedProgress,
              message: 'Uploading artwork: ${(progress * 100).toInt()}%',
            );
          },
        );
      }

      // Step 5: Complete upload and trigger processing
      state = const UploadState.uploading(
        progress: 0.8,
        message: 'Finalizing upload...',
      );

      await _repository.completeUpload(initResponse.trackId);

      // Step 6: Start polling for processing status
      state = UploadState.processing(
        trackId: initResponse.trackId,
        progress: 0,
      );

      _pollProcessingStatus(initResponse.trackId);
    } catch (e, stackTrace) {
      print('=== Upload Error ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      state = UploadState.error(message: e.toString());
    }
  }

  /// Poll processing status until completed or failed
  Future<void> _pollProcessingStatus(String trackId) async {
    try {
      // Poll for max 30 seconds (15 attempts * 2 seconds)
      for (var i = 0; i < 15; i++) {
        await Future<void>.delayed(_pollInterval);

        final status = await _repository.getProcessingStatus(trackId);

        if (status.isCompleted) {
          state = UploadState.completed(trackId: trackId);
          return;
        } else if (status.isFailed) {
          state = UploadState.error(
            message: status.error ?? 'Processing failed',
          );
          return;
        } else if (status.isProcessing) {
          state = UploadState.processing(
            trackId: trackId,
            progress: status.progress,
          );
        }
      }

      // Timeout reached - treat as completed since upload succeeded
      state = UploadState.completed(trackId: trackId);
    } catch (e) {
      // If status check fails, treat as completed since upload succeeded
      state = UploadState.completed(trackId: trackId);
    }
  }

  /// Reset to idle state
  void reset() {
    state = const UploadState.idle();
  }

  /// Retry upload
  Future<void> retry({
    required String title,
    required String artistName,
    required File audioFile,
    File? artworkFile,
  }) async {
    reset();
    await uploadTrack(
      title: title,
      artistName: artistName,
      audioFile: audioFile,
      artworkFile: artworkFile,
    );
  }
}
