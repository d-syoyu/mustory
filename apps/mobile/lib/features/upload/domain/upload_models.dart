import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_models.freezed.dart';

/// Request to initialize track upload
@freezed
class TrackUploadInitRequest with _$TrackUploadInitRequest {
  const factory TrackUploadInitRequest({
    required String title,
    required String artistName,
    required String fileExtension,
    required int fileSize,
    String? artworkExtension,
  }) = _TrackUploadInitRequest;

  factory TrackUploadInitRequest.fromJson(Map<String, dynamic> json) {
    return TrackUploadInitRequest(
      title: json['title'] as String,
      artistName: json['artist_name'] as String,
      fileExtension: json['file_extension'] as String,
      fileSize: json['file_size'] as int,
      artworkExtension: json['artwork_extension'] as String?,
    );
  }

  const TrackUploadInitRequest._();

  Map<String, dynamic> toJson() => {
        'title': title,
        'artist_name': artistName,
        'file_extension': fileExtension,
        'file_size': fileSize,
        if (artworkExtension != null) 'artwork_extension': artworkExtension,
      };
}

/// Response from upload initialization (Presigned PUT URLs)
@freezed
class TrackUploadInitResponse with _$TrackUploadInitResponse {
  const factory TrackUploadInitResponse({
    required String trackId,
    required String audioUploadUrl,
    String? artworkUploadUrl,
  }) = _TrackUploadInitResponse;

  factory TrackUploadInitResponse.fromJson(Map<String, dynamic> json) {
    return TrackUploadInitResponse(
      trackId: json['track_id'] as String,
      audioUploadUrl: json['audio_upload_url'] as String,
      artworkUploadUrl: json['artwork_upload_url'] as String?,
    );
  }
}

/// Track processing status
@freezed
class TrackProcessingStatus with _$TrackProcessingStatus {
  const factory TrackProcessingStatus({
    required String trackId,
    required String status, // pending, processing, completed, failed
    int? progress,
    String? error,
  }) = _TrackProcessingStatus;

  factory TrackProcessingStatus.fromJson(Map<String, dynamic> json) {
    return TrackProcessingStatus(
      trackId: json['track_id'] as String,
      status: json['status'] as String,
      progress: json['progress'] as int?,
      error: json['error'] as String?,
    );
  }

  const TrackProcessingStatus._();

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}

/// Upload state for UI
@freezed
class UploadState with _$UploadState {
  const factory UploadState.idle() = _Idle;
  const factory UploadState.picking() = _Picking;
  const factory UploadState.initializing() = _Initializing;
  const factory UploadState.uploading({
    required double progress,
    String? message,
  }) = _Uploading;
  const factory UploadState.processing({
    required String trackId,
    int? progress,
  }) = _Processing;
  const factory UploadState.completed({
    required String trackId,
  }) = _Completed;
  const factory UploadState.error({
    required String message,
  }) = _Error;
}
