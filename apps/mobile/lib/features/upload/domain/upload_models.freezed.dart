// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrackUploadInitRequest {
  String get title => throw _privateConstructorUsedError;
  String get artistName => throw _privateConstructorUsedError;
  String get fileExtension => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String? get artworkExtension => throw _privateConstructorUsedError;

  /// Create a copy of TrackUploadInitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackUploadInitRequestCopyWith<TrackUploadInitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackUploadInitRequestCopyWith<$Res> {
  factory $TrackUploadInitRequestCopyWith(TrackUploadInitRequest value,
          $Res Function(TrackUploadInitRequest) then) =
      _$TrackUploadInitRequestCopyWithImpl<$Res, TrackUploadInitRequest>;
  @useResult
  $Res call(
      {String title,
      String artistName,
      String fileExtension,
      int fileSize,
      String? artworkExtension});
}

/// @nodoc
class _$TrackUploadInitRequestCopyWithImpl<$Res,
        $Val extends TrackUploadInitRequest>
    implements $TrackUploadInitRequestCopyWith<$Res> {
  _$TrackUploadInitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackUploadInitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? artistName = null,
    Object? fileExtension = null,
    Object? fileSize = null,
    Object? artworkExtension = freezed,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      fileExtension: null == fileExtension
          ? _value.fileExtension
          : fileExtension // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      artworkExtension: freezed == artworkExtension
          ? _value.artworkExtension
          : artworkExtension // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackUploadInitRequestImplCopyWith<$Res>
    implements $TrackUploadInitRequestCopyWith<$Res> {
  factory _$$TrackUploadInitRequestImplCopyWith(
          _$TrackUploadInitRequestImpl value,
          $Res Function(_$TrackUploadInitRequestImpl) then) =
      __$$TrackUploadInitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String artistName,
      String fileExtension,
      int fileSize,
      String? artworkExtension});
}

/// @nodoc
class __$$TrackUploadInitRequestImplCopyWithImpl<$Res>
    extends _$TrackUploadInitRequestCopyWithImpl<$Res,
        _$TrackUploadInitRequestImpl>
    implements _$$TrackUploadInitRequestImplCopyWith<$Res> {
  __$$TrackUploadInitRequestImplCopyWithImpl(
      _$TrackUploadInitRequestImpl _value,
      $Res Function(_$TrackUploadInitRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackUploadInitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? artistName = null,
    Object? fileExtension = null,
    Object? fileSize = null,
    Object? artworkExtension = freezed,
  }) {
    return _then(_$TrackUploadInitRequestImpl(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      fileExtension: null == fileExtension
          ? _value.fileExtension
          : fileExtension // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: null == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int,
      artworkExtension: freezed == artworkExtension
          ? _value.artworkExtension
          : artworkExtension // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TrackUploadInitRequestImpl extends _TrackUploadInitRequest {
  const _$TrackUploadInitRequestImpl(
      {required this.title,
      required this.artistName,
      required this.fileExtension,
      required this.fileSize,
      this.artworkExtension})
      : super._();

  @override
  final String title;
  @override
  final String artistName;
  @override
  final String fileExtension;
  @override
  final int fileSize;
  @override
  final String? artworkExtension;

  @override
  String toString() {
    return 'TrackUploadInitRequest(title: $title, artistName: $artistName, fileExtension: $fileExtension, fileSize: $fileSize, artworkExtension: $artworkExtension)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackUploadInitRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.fileExtension, fileExtension) ||
                other.fileExtension == fileExtension) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.artworkExtension, artworkExtension) ||
                other.artworkExtension == artworkExtension));
  }

  @override
  int get hashCode => Object.hash(runtimeType, title, artistName, fileExtension,
      fileSize, artworkExtension);

  /// Create a copy of TrackUploadInitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackUploadInitRequestImplCopyWith<_$TrackUploadInitRequestImpl>
      get copyWith => __$$TrackUploadInitRequestImplCopyWithImpl<
          _$TrackUploadInitRequestImpl>(this, _$identity);
}

abstract class _TrackUploadInitRequest extends TrackUploadInitRequest {
  const factory _TrackUploadInitRequest(
      {required final String title,
      required final String artistName,
      required final String fileExtension,
      required final int fileSize,
      final String? artworkExtension}) = _$TrackUploadInitRequestImpl;
  const _TrackUploadInitRequest._() : super._();

  @override
  String get title;
  @override
  String get artistName;
  @override
  String get fileExtension;
  @override
  int get fileSize;
  @override
  String? get artworkExtension;

  /// Create a copy of TrackUploadInitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackUploadInitRequestImplCopyWith<_$TrackUploadInitRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrackUploadInitResponse {
  String get trackId => throw _privateConstructorUsedError;
  String get audioUploadUrl => throw _privateConstructorUsedError;
  String? get artworkUploadUrl => throw _privateConstructorUsedError;

  /// Create a copy of TrackUploadInitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackUploadInitResponseCopyWith<TrackUploadInitResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackUploadInitResponseCopyWith<$Res> {
  factory $TrackUploadInitResponseCopyWith(TrackUploadInitResponse value,
          $Res Function(TrackUploadInitResponse) then) =
      _$TrackUploadInitResponseCopyWithImpl<$Res, TrackUploadInitResponse>;
  @useResult
  $Res call({String trackId, String audioUploadUrl, String? artworkUploadUrl});
}

/// @nodoc
class _$TrackUploadInitResponseCopyWithImpl<$Res,
        $Val extends TrackUploadInitResponse>
    implements $TrackUploadInitResponseCopyWith<$Res> {
  _$TrackUploadInitResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackUploadInitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
    Object? audioUploadUrl = null,
    Object? artworkUploadUrl = freezed,
  }) {
    return _then(_value.copyWith(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUploadUrl: null == audioUploadUrl
          ? _value.audioUploadUrl
          : audioUploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUploadUrl: freezed == artworkUploadUrl
          ? _value.artworkUploadUrl
          : artworkUploadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackUploadInitResponseImplCopyWith<$Res>
    implements $TrackUploadInitResponseCopyWith<$Res> {
  factory _$$TrackUploadInitResponseImplCopyWith(
          _$TrackUploadInitResponseImpl value,
          $Res Function(_$TrackUploadInitResponseImpl) then) =
      __$$TrackUploadInitResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String trackId, String audioUploadUrl, String? artworkUploadUrl});
}

/// @nodoc
class __$$TrackUploadInitResponseImplCopyWithImpl<$Res>
    extends _$TrackUploadInitResponseCopyWithImpl<$Res,
        _$TrackUploadInitResponseImpl>
    implements _$$TrackUploadInitResponseImplCopyWith<$Res> {
  __$$TrackUploadInitResponseImplCopyWithImpl(
      _$TrackUploadInitResponseImpl _value,
      $Res Function(_$TrackUploadInitResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackUploadInitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
    Object? audioUploadUrl = null,
    Object? artworkUploadUrl = freezed,
  }) {
    return _then(_$TrackUploadInitResponseImpl(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      audioUploadUrl: null == audioUploadUrl
          ? _value.audioUploadUrl
          : audioUploadUrl // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUploadUrl: freezed == artworkUploadUrl
          ? _value.artworkUploadUrl
          : artworkUploadUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TrackUploadInitResponseImpl implements _TrackUploadInitResponse {
  const _$TrackUploadInitResponseImpl(
      {required this.trackId,
      required this.audioUploadUrl,
      this.artworkUploadUrl});

  @override
  final String trackId;
  @override
  final String audioUploadUrl;
  @override
  final String? artworkUploadUrl;

  @override
  String toString() {
    return 'TrackUploadInitResponse(trackId: $trackId, audioUploadUrl: $audioUploadUrl, artworkUploadUrl: $artworkUploadUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackUploadInitResponseImpl &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.audioUploadUrl, audioUploadUrl) ||
                other.audioUploadUrl == audioUploadUrl) &&
            (identical(other.artworkUploadUrl, artworkUploadUrl) ||
                other.artworkUploadUrl == artworkUploadUrl));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, trackId, audioUploadUrl, artworkUploadUrl);

  /// Create a copy of TrackUploadInitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackUploadInitResponseImplCopyWith<_$TrackUploadInitResponseImpl>
      get copyWith => __$$TrackUploadInitResponseImplCopyWithImpl<
          _$TrackUploadInitResponseImpl>(this, _$identity);
}

abstract class _TrackUploadInitResponse implements TrackUploadInitResponse {
  const factory _TrackUploadInitResponse(
      {required final String trackId,
      required final String audioUploadUrl,
      final String? artworkUploadUrl}) = _$TrackUploadInitResponseImpl;

  @override
  String get trackId;
  @override
  String get audioUploadUrl;
  @override
  String? get artworkUploadUrl;

  /// Create a copy of TrackUploadInitResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackUploadInitResponseImplCopyWith<_$TrackUploadInitResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TrackProcessingStatus {
  String get trackId => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // pending, processing, completed, failed
  int? get progress => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of TrackProcessingStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackProcessingStatusCopyWith<TrackProcessingStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackProcessingStatusCopyWith<$Res> {
  factory $TrackProcessingStatusCopyWith(TrackProcessingStatus value,
          $Res Function(TrackProcessingStatus) then) =
      _$TrackProcessingStatusCopyWithImpl<$Res, TrackProcessingStatus>;
  @useResult
  $Res call({String trackId, String status, int? progress, String? error});
}

/// @nodoc
class _$TrackProcessingStatusCopyWithImpl<$Res,
        $Val extends TrackProcessingStatus>
    implements $TrackProcessingStatusCopyWith<$Res> {
  _$TrackProcessingStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackProcessingStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
    Object? status = null,
    Object? progress = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrackProcessingStatusImplCopyWith<$Res>
    implements $TrackProcessingStatusCopyWith<$Res> {
  factory _$$TrackProcessingStatusImplCopyWith(
          _$TrackProcessingStatusImpl value,
          $Res Function(_$TrackProcessingStatusImpl) then) =
      __$$TrackProcessingStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String trackId, String status, int? progress, String? error});
}

/// @nodoc
class __$$TrackProcessingStatusImplCopyWithImpl<$Res>
    extends _$TrackProcessingStatusCopyWithImpl<$Res,
        _$TrackProcessingStatusImpl>
    implements _$$TrackProcessingStatusImplCopyWith<$Res> {
  __$$TrackProcessingStatusImplCopyWithImpl(_$TrackProcessingStatusImpl _value,
      $Res Function(_$TrackProcessingStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackProcessingStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
    Object? status = null,
    Object? progress = freezed,
    Object? error = freezed,
  }) {
    return _then(_$TrackProcessingStatusImpl(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TrackProcessingStatusImpl extends _TrackProcessingStatus {
  const _$TrackProcessingStatusImpl(
      {required this.trackId, required this.status, this.progress, this.error})
      : super._();

  @override
  final String trackId;
  @override
  final String status;
// pending, processing, completed, failed
  @override
  final int? progress;
  @override
  final String? error;

  @override
  String toString() {
    return 'TrackProcessingStatus(trackId: $trackId, status: $status, progress: $progress, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackProcessingStatusImpl &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, trackId, status, progress, error);

  /// Create a copy of TrackProcessingStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackProcessingStatusImplCopyWith<_$TrackProcessingStatusImpl>
      get copyWith => __$$TrackProcessingStatusImplCopyWithImpl<
          _$TrackProcessingStatusImpl>(this, _$identity);
}

abstract class _TrackProcessingStatus extends TrackProcessingStatus {
  const factory _TrackProcessingStatus(
      {required final String trackId,
      required final String status,
      final int? progress,
      final String? error}) = _$TrackProcessingStatusImpl;
  const _TrackProcessingStatus._() : super._();

  @override
  String get trackId;
  @override
  String get status; // pending, processing, completed, failed
  @override
  int? get progress;
  @override
  String? get error;

  /// Create a copy of TrackProcessingStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackProcessingStatusImplCopyWith<_$TrackProcessingStatusImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UploadState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UploadStateCopyWith<$Res> {
  factory $UploadStateCopyWith(
          UploadState value, $Res Function(UploadState) then) =
      _$UploadStateCopyWithImpl<$Res, UploadState>;
}

/// @nodoc
class _$UploadStateCopyWithImpl<$Res, $Val extends UploadState>
    implements $UploadStateCopyWith<$Res> {
  _$UploadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
          _$IdleImpl value, $Res Function(_$IdleImpl) then) =
      __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'UploadState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements UploadState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$PickingImplCopyWith<$Res> {
  factory _$$PickingImplCopyWith(
          _$PickingImpl value, $Res Function(_$PickingImpl) then) =
      __$$PickingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PickingImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$PickingImpl>
    implements _$$PickingImplCopyWith<$Res> {
  __$$PickingImplCopyWithImpl(
      _$PickingImpl _value, $Res Function(_$PickingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PickingImpl implements _Picking {
  const _$PickingImpl();

  @override
  String toString() {
    return 'UploadState.picking()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PickingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return picking();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return picking?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (picking != null) {
      return picking();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return picking(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return picking?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (picking != null) {
      return picking(this);
    }
    return orElse();
  }
}

abstract class _Picking implements UploadState {
  const factory _Picking() = _$PickingImpl;
}

/// @nodoc
abstract class _$$InitializingImplCopyWith<$Res> {
  factory _$$InitializingImplCopyWith(
          _$InitializingImpl value, $Res Function(_$InitializingImpl) then) =
      __$$InitializingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitializingImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$InitializingImpl>
    implements _$$InitializingImplCopyWith<$Res> {
  __$$InitializingImplCopyWithImpl(
      _$InitializingImpl _value, $Res Function(_$InitializingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitializingImpl implements _Initializing {
  const _$InitializingImpl();

  @override
  String toString() {
    return 'UploadState.initializing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitializingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return initializing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return initializing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initializing != null) {
      return initializing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return initializing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return initializing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initializing != null) {
      return initializing(this);
    }
    return orElse();
  }
}

abstract class _Initializing implements UploadState {
  const factory _Initializing() = _$InitializingImpl;
}

/// @nodoc
abstract class _$$UploadingImplCopyWith<$Res> {
  factory _$$UploadingImplCopyWith(
          _$UploadingImpl value, $Res Function(_$UploadingImpl) then) =
      __$$UploadingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({double progress, String? message});
}

/// @nodoc
class __$$UploadingImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$UploadingImpl>
    implements _$$UploadingImplCopyWith<$Res> {
  __$$UploadingImplCopyWithImpl(
      _$UploadingImpl _value, $Res Function(_$UploadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? progress = null,
    Object? message = freezed,
  }) {
    return _then(_$UploadingImpl(
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UploadingImpl implements _Uploading {
  const _$UploadingImpl({required this.progress, this.message});

  @override
  final double progress;
  @override
  final String? message;

  @override
  String toString() {
    return 'UploadState.uploading(progress: $progress, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UploadingImpl &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress, message);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UploadingImplCopyWith<_$UploadingImpl> get copyWith =>
      __$$UploadingImplCopyWithImpl<_$UploadingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return uploading(progress, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return uploading?.call(progress, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(progress, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return uploading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return uploading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (uploading != null) {
      return uploading(this);
    }
    return orElse();
  }
}

abstract class _Uploading implements UploadState {
  const factory _Uploading(
      {required final double progress,
      final String? message}) = _$UploadingImpl;

  double get progress;
  String? get message;

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UploadingImplCopyWith<_$UploadingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
          _$ProcessingImpl value, $Res Function(_$ProcessingImpl) then) =
      __$$ProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String trackId, int? progress});
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
      _$ProcessingImpl _value, $Res Function(_$ProcessingImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
    Object? progress = freezed,
  }) {
    return _then(_$ProcessingImpl(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
      progress: freezed == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl({required this.trackId, this.progress});

  @override
  final String trackId;
  @override
  final int? progress;

  @override
  String toString() {
    return 'UploadState.processing(trackId: $trackId, progress: $progress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingImpl &&
            (identical(other.trackId, trackId) || other.trackId == trackId) &&
            (identical(other.progress, progress) ||
                other.progress == progress));
  }

  @override
  int get hashCode => Object.hash(runtimeType, trackId, progress);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      __$$ProcessingImplCopyWithImpl<_$ProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return processing(trackId, progress);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return processing?.call(trackId, progress);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(trackId, progress);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements UploadState {
  const factory _Processing(
      {required final String trackId, final int? progress}) = _$ProcessingImpl;

  String get trackId;
  int? get progress;

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompletedImplCopyWith<$Res> {
  factory _$$CompletedImplCopyWith(
          _$CompletedImpl value, $Res Function(_$CompletedImpl) then) =
      __$$CompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String trackId});
}

/// @nodoc
class __$$CompletedImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$CompletedImpl>
    implements _$$CompletedImplCopyWith<$Res> {
  __$$CompletedImplCopyWithImpl(
      _$CompletedImpl _value, $Res Function(_$CompletedImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? trackId = null,
  }) {
    return _then(_$CompletedImpl(
      trackId: null == trackId
          ? _value.trackId
          : trackId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CompletedImpl implements _Completed {
  const _$CompletedImpl({required this.trackId});

  @override
  final String trackId;

  @override
  String toString() {
    return 'UploadState.completed(trackId: $trackId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletedImpl &&
            (identical(other.trackId, trackId) || other.trackId == trackId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, trackId);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
      __$$CompletedImplCopyWithImpl<_$CompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return completed(trackId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return completed?.call(trackId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(trackId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class _Completed implements UploadState {
  const factory _Completed({required final String trackId}) = _$CompletedImpl;

  String get trackId;

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$UploadStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'UploadState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function() picking,
    required TResult Function() initializing,
    required TResult Function(double progress, String? message) uploading,
    required TResult Function(String trackId, int? progress) processing,
    required TResult Function(String trackId) completed,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function()? picking,
    TResult? Function()? initializing,
    TResult? Function(double progress, String? message)? uploading,
    TResult? Function(String trackId, int? progress)? processing,
    TResult? Function(String trackId)? completed,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function()? picking,
    TResult Function()? initializing,
    TResult Function(double progress, String? message)? uploading,
    TResult Function(String trackId, int? progress)? processing,
    TResult Function(String trackId)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Picking value) picking,
    required TResult Function(_Initializing value) initializing,
    required TResult Function(_Uploading value) uploading,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Picking value)? picking,
    TResult? Function(_Initializing value)? initializing,
    TResult? Function(_Uploading value)? uploading,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Picking value)? picking,
    TResult Function(_Initializing value)? initializing,
    TResult Function(_Uploading value)? uploading,
    TResult Function(_Processing value)? processing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements UploadState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of UploadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
