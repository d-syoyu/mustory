// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Track {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get artistName => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get artworkUrl => throw _privateConstructorUsedError;
  String get hlsUrl => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  int get trackCommentCount => throw _privateConstructorUsedError;
  int get storyCommentCount => throw _privateConstructorUsedError;
  bool get isLiked => throw _privateConstructorUsedError;
  Map<String, dynamic>? get story => throw _privateConstructorUsedError;
  UserSummary? get user => throw _privateConstructorUsedError;
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Audio features
  int? get durationSeconds => throw _privateConstructorUsedError;
  double? get bpm => throw _privateConstructorUsedError;
  double? get loudnessLufs => throw _privateConstructorUsedError;
  double? get moodValence => throw _privateConstructorUsedError;
  double? get moodEnergy => throw _privateConstructorUsedError;
  bool? get hasVocals => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackCopyWith<Track> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackCopyWith<$Res> {
  factory $TrackCopyWith(Track value, $Res Function(Track) then) =
      _$TrackCopyWithImpl<$Res, Track>;
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String userId,
      String artworkUrl,
      String hlsUrl,
      int likeCount,
      int viewCount,
      int trackCommentCount,
      int storyCommentCount,
      bool isLiked,
      Map<String, dynamic>? story,
      UserSummary? user,
      DateTime? createdAt,
      int? durationSeconds,
      double? bpm,
      double? loudnessLufs,
      double? moodValence,
      double? moodEnergy,
      bool? hasVocals,
      List<String> tags});

  $UserSummaryCopyWith<$Res>? get user;
}

/// @nodoc
class _$TrackCopyWithImpl<$Res, $Val extends Track>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? userId = null,
    Object? artworkUrl = null,
    Object? hlsUrl = null,
    Object? likeCount = null,
    Object? viewCount = null,
    Object? trackCommentCount = null,
    Object? storyCommentCount = null,
    Object? isLiked = null,
    Object? story = freezed,
    Object? user = freezed,
    Object? createdAt = freezed,
    Object? durationSeconds = freezed,
    Object? bpm = freezed,
    Object? loudnessLufs = freezed,
    Object? moodValence = freezed,
    Object? moodEnergy = freezed,
    Object? hasVocals = freezed,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUrl: null == artworkUrl
          ? _value.artworkUrl
          : artworkUrl // ignore: cast_nullable_to_non_nullable
              as String,
      hlsUrl: null == hlsUrl
          ? _value.hlsUrl
          : hlsUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      trackCommentCount: null == trackCommentCount
          ? _value.trackCommentCount
          : trackCommentCount // ignore: cast_nullable_to_non_nullable
              as int,
      storyCommentCount: null == storyCommentCount
          ? _value.storyCommentCount
          : storyCommentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      story: freezed == story
          ? _value.story
          : story // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummary?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      bpm: freezed == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as double?,
      loudnessLufs: freezed == loudnessLufs
          ? _value.loudnessLufs
          : loudnessLufs // ignore: cast_nullable_to_non_nullable
              as double?,
      moodValence: freezed == moodValence
          ? _value.moodValence
          : moodValence // ignore: cast_nullable_to_non_nullable
              as double?,
      moodEnergy: freezed == moodEnergy
          ? _value.moodEnergy
          : moodEnergy // ignore: cast_nullable_to_non_nullable
              as double?,
      hasVocals: freezed == hasVocals
          ? _value.hasVocals
          : hasVocals // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserSummaryCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserSummaryCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackImplCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$$TrackImplCopyWith(
          _$TrackImpl value, $Res Function(_$TrackImpl) then) =
      __$$TrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String artistName,
      String userId,
      String artworkUrl,
      String hlsUrl,
      int likeCount,
      int viewCount,
      int trackCommentCount,
      int storyCommentCount,
      bool isLiked,
      Map<String, dynamic>? story,
      UserSummary? user,
      DateTime? createdAt,
      int? durationSeconds,
      double? bpm,
      double? loudnessLufs,
      double? moodValence,
      double? moodEnergy,
      bool? hasVocals,
      List<String> tags});

  @override
  $UserSummaryCopyWith<$Res>? get user;
}

/// @nodoc
class __$$TrackImplCopyWithImpl<$Res>
    extends _$TrackCopyWithImpl<$Res, _$TrackImpl>
    implements _$$TrackImplCopyWith<$Res> {
  __$$TrackImplCopyWithImpl(
      _$TrackImpl _value, $Res Function(_$TrackImpl) _then)
      : super(_value, _then);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? artistName = null,
    Object? userId = null,
    Object? artworkUrl = null,
    Object? hlsUrl = null,
    Object? likeCount = null,
    Object? viewCount = null,
    Object? trackCommentCount = null,
    Object? storyCommentCount = null,
    Object? isLiked = null,
    Object? story = freezed,
    Object? user = freezed,
    Object? createdAt = freezed,
    Object? durationSeconds = freezed,
    Object? bpm = freezed,
    Object? loudnessLufs = freezed,
    Object? moodValence = freezed,
    Object? moodEnergy = freezed,
    Object? hasVocals = freezed,
    Object? tags = null,
  }) {
    return _then(_$TrackImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      artistName: null == artistName
          ? _value.artistName
          : artistName // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      artworkUrl: null == artworkUrl
          ? _value.artworkUrl
          : artworkUrl // ignore: cast_nullable_to_non_nullable
              as String,
      hlsUrl: null == hlsUrl
          ? _value.hlsUrl
          : hlsUrl // ignore: cast_nullable_to_non_nullable
              as String,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      viewCount: null == viewCount
          ? _value.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      trackCommentCount: null == trackCommentCount
          ? _value.trackCommentCount
          : trackCommentCount // ignore: cast_nullable_to_non_nullable
              as int,
      storyCommentCount: null == storyCommentCount
          ? _value.storyCommentCount
          : storyCommentCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      story: freezed == story
          ? _value._story
          : story // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserSummary?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      durationSeconds: freezed == durationSeconds
          ? _value.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      bpm: freezed == bpm
          ? _value.bpm
          : bpm // ignore: cast_nullable_to_non_nullable
              as double?,
      loudnessLufs: freezed == loudnessLufs
          ? _value.loudnessLufs
          : loudnessLufs // ignore: cast_nullable_to_non_nullable
              as double?,
      moodValence: freezed == moodValence
          ? _value.moodValence
          : moodValence // ignore: cast_nullable_to_non_nullable
              as double?,
      moodEnergy: freezed == moodEnergy
          ? _value.moodEnergy
          : moodEnergy // ignore: cast_nullable_to_non_nullable
              as double?,
      hasVocals: freezed == hasVocals
          ? _value.hasVocals
          : hasVocals // ignore: cast_nullable_to_non_nullable
              as bool?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$TrackImpl extends _Track {
  const _$TrackImpl(
      {required this.id,
      required this.title,
      required this.artistName,
      required this.userId,
      required this.artworkUrl,
      required this.hlsUrl,
      this.likeCount = 0,
      this.viewCount = 0,
      this.trackCommentCount = 0,
      this.storyCommentCount = 0,
      this.isLiked = false,
      final Map<String, dynamic>? story,
      this.user,
      this.createdAt,
      this.durationSeconds,
      this.bpm,
      this.loudnessLufs,
      this.moodValence,
      this.moodEnergy,
      this.hasVocals,
      final List<String> tags = const <String>[]})
      : _story = story,
        _tags = tags,
        super._();

  @override
  final String id;
  @override
  final String title;
  @override
  final String artistName;
  @override
  final String userId;
  @override
  final String artworkUrl;
  @override
  final String hlsUrl;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int viewCount;
  @override
  @JsonKey()
  final int trackCommentCount;
  @override
  @JsonKey()
  final int storyCommentCount;
  @override
  @JsonKey()
  final bool isLiked;
  final Map<String, dynamic>? _story;
  @override
  Map<String, dynamic>? get story {
    final value = _story;
    if (value == null) return null;
    if (_story is EqualUnmodifiableMapView) return _story;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final UserSummary? user;
  @override
  final DateTime? createdAt;
// Audio features
  @override
  final int? durationSeconds;
  @override
  final double? bpm;
  @override
  final double? loudnessLufs;
  @override
  final double? moodValence;
  @override
  final double? moodEnergy;
  @override
  final bool? hasVocals;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'Track(id: $id, title: $title, artistName: $artistName, userId: $userId, artworkUrl: $artworkUrl, hlsUrl: $hlsUrl, likeCount: $likeCount, viewCount: $viewCount, trackCommentCount: $trackCommentCount, storyCommentCount: $storyCommentCount, isLiked: $isLiked, story: $story, user: $user, createdAt: $createdAt, durationSeconds: $durationSeconds, bpm: $bpm, loudnessLufs: $loudnessLufs, moodValence: $moodValence, moodEnergy: $moodEnergy, hasVocals: $hasVocals, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.artistName, artistName) ||
                other.artistName == artistName) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.artworkUrl, artworkUrl) ||
                other.artworkUrl == artworkUrl) &&
            (identical(other.hlsUrl, hlsUrl) || other.hlsUrl == hlsUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.trackCommentCount, trackCommentCount) ||
                other.trackCommentCount == trackCommentCount) &&
            (identical(other.storyCommentCount, storyCommentCount) ||
                other.storyCommentCount == storyCommentCount) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            const DeepCollectionEquality().equals(other._story, _story) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.bpm, bpm) || other.bpm == bpm) &&
            (identical(other.loudnessLufs, loudnessLufs) ||
                other.loudnessLufs == loudnessLufs) &&
            (identical(other.moodValence, moodValence) ||
                other.moodValence == moodValence) &&
            (identical(other.moodEnergy, moodEnergy) ||
                other.moodEnergy == moodEnergy) &&
            (identical(other.hasVocals, hasVocals) ||
                other.hasVocals == hasVocals) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        artistName,
        userId,
        artworkUrl,
        hlsUrl,
        likeCount,
        viewCount,
        trackCommentCount,
        storyCommentCount,
        isLiked,
        const DeepCollectionEquality().hash(_story),
        user,
        createdAt,
        durationSeconds,
        bpm,
        loudnessLufs,
        moodValence,
        moodEnergy,
        hasVocals,
        const DeepCollectionEquality().hash(_tags)
      ]);

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      __$$TrackImplCopyWithImpl<_$TrackImpl>(this, _$identity);
}

abstract class _Track extends Track {
  const factory _Track(
      {required final String id,
      required final String title,
      required final String artistName,
      required final String userId,
      required final String artworkUrl,
      required final String hlsUrl,
      final int likeCount,
      final int viewCount,
      final int trackCommentCount,
      final int storyCommentCount,
      final bool isLiked,
      final Map<String, dynamic>? story,
      final UserSummary? user,
      final DateTime? createdAt,
      final int? durationSeconds,
      final double? bpm,
      final double? loudnessLufs,
      final double? moodValence,
      final double? moodEnergy,
      final bool? hasVocals,
      final List<String> tags}) = _$TrackImpl;
  const _Track._() : super._();

  @override
  String get id;
  @override
  String get title;
  @override
  String get artistName;
  @override
  String get userId;
  @override
  String get artworkUrl;
  @override
  String get hlsUrl;
  @override
  int get likeCount;
  @override
  int get viewCount;
  @override
  int get trackCommentCount;
  @override
  int get storyCommentCount;
  @override
  bool get isLiked;
  @override
  Map<String, dynamic>? get story;
  @override
  UserSummary? get user;
  @override
  DateTime? get createdAt; // Audio features
  @override
  int? get durationSeconds;
  @override
  double? get bpm;
  @override
  double? get loudnessLufs;
  @override
  double? get moodValence;
  @override
  double? get moodEnergy;
  @override
  bool? get hasVocals;
  @override
  List<String> get tags;

  /// Create a copy of Track
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackImplCopyWith<_$TrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
