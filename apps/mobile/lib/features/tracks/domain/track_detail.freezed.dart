// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrackDetail {
  Track get track => throw _privateConstructorUsedError;
  List<Comment> get trackComments => throw _privateConstructorUsedError;
  List<Comment> get storyComments => throw _privateConstructorUsedError;

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrackDetailCopyWith<TrackDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrackDetailCopyWith<$Res> {
  factory $TrackDetailCopyWith(
          TrackDetail value, $Res Function(TrackDetail) then) =
      _$TrackDetailCopyWithImpl<$Res, TrackDetail>;
  @useResult
  $Res call(
      {Track track, List<Comment> trackComments, List<Comment> storyComments});

  $TrackCopyWith<$Res> get track;
}

/// @nodoc
class _$TrackDetailCopyWithImpl<$Res, $Val extends TrackDetail>
    implements $TrackDetailCopyWith<$Res> {
  _$TrackDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? track = null,
    Object? trackComments = null,
    Object? storyComments = null,
  }) {
    return _then(_value.copyWith(
      track: null == track
          ? _value.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track,
      trackComments: null == trackComments
          ? _value.trackComments
          : trackComments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
      storyComments: null == storyComments
          ? _value.storyComments
          : storyComments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ) as $Val);
  }

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackCopyWith<$Res> get track {
    return $TrackCopyWith<$Res>(_value.track, (value) {
      return _then(_value.copyWith(track: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrackDetailImplCopyWith<$Res>
    implements $TrackDetailCopyWith<$Res> {
  factory _$$TrackDetailImplCopyWith(
          _$TrackDetailImpl value, $Res Function(_$TrackDetailImpl) then) =
      __$$TrackDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Track track, List<Comment> trackComments, List<Comment> storyComments});

  @override
  $TrackCopyWith<$Res> get track;
}

/// @nodoc
class __$$TrackDetailImplCopyWithImpl<$Res>
    extends _$TrackDetailCopyWithImpl<$Res, _$TrackDetailImpl>
    implements _$$TrackDetailImplCopyWith<$Res> {
  __$$TrackDetailImplCopyWithImpl(
      _$TrackDetailImpl _value, $Res Function(_$TrackDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? track = null,
    Object? trackComments = null,
    Object? storyComments = null,
  }) {
    return _then(_$TrackDetailImpl(
      track: null == track
          ? _value.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track,
      trackComments: null == trackComments
          ? _value._trackComments
          : trackComments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
      storyComments: null == storyComments
          ? _value._storyComments
          : storyComments // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ));
  }
}

/// @nodoc

class _$TrackDetailImpl implements _TrackDetail {
  const _$TrackDetailImpl(
      {required this.track,
      required final List<Comment> trackComments,
      required final List<Comment> storyComments})
      : _trackComments = trackComments,
        _storyComments = storyComments;

  @override
  final Track track;
  final List<Comment> _trackComments;
  @override
  List<Comment> get trackComments {
    if (_trackComments is EqualUnmodifiableListView) return _trackComments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_trackComments);
  }

  final List<Comment> _storyComments;
  @override
  List<Comment> get storyComments {
    if (_storyComments is EqualUnmodifiableListView) return _storyComments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_storyComments);
  }

  @override
  String toString() {
    return 'TrackDetail(track: $track, trackComments: $trackComments, storyComments: $storyComments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrackDetailImpl &&
            (identical(other.track, track) || other.track == track) &&
            const DeepCollectionEquality()
                .equals(other._trackComments, _trackComments) &&
            const DeepCollectionEquality()
                .equals(other._storyComments, _storyComments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      track,
      const DeepCollectionEquality().hash(_trackComments),
      const DeepCollectionEquality().hash(_storyComments));

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrackDetailImplCopyWith<_$TrackDetailImpl> get copyWith =>
      __$$TrackDetailImplCopyWithImpl<_$TrackDetailImpl>(this, _$identity);
}

abstract class _TrackDetail implements TrackDetail {
  const factory _TrackDetail(
      {required final Track track,
      required final List<Comment> trackComments,
      required final List<Comment> storyComments}) = _$TrackDetailImpl;

  @override
  Track get track;
  @override
  List<Comment> get trackComments;
  @override
  List<Comment> get storyComments;

  /// Create a copy of TrackDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrackDetailImplCopyWith<_$TrackDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
