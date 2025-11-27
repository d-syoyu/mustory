// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FeedUser _$FeedUserFromJson(Map<String, dynamic> json) {
  return _FeedUser.fromJson(json);
}

/// @nodoc
mixin _$FeedUser {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this FeedUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedUserCopyWith<FeedUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedUserCopyWith<$Res> {
  factory $FeedUserCopyWith(FeedUser value, $Res Function(FeedUser) then) =
      _$FeedUserCopyWithImpl<$Res, FeedUser>;
  @useResult
  $Res call(
      {String id,
      String username,
      String displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl});
}

/// @nodoc
class _$FeedUserCopyWithImpl<$Res, $Val extends FeedUser>
    implements $FeedUserCopyWith<$Res> {
  _$FeedUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FeedUserImplCopyWith<$Res>
    implements $FeedUserCopyWith<$Res> {
  factory _$$FeedUserImplCopyWith(
          _$FeedUserImpl value, $Res Function(_$FeedUserImpl) then) =
      __$$FeedUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String username,
      String displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl});
}

/// @nodoc
class __$$FeedUserImplCopyWithImpl<$Res>
    extends _$FeedUserCopyWithImpl<$Res, _$FeedUserImpl>
    implements _$$FeedUserImplCopyWith<$Res> {
  __$$FeedUserImplCopyWithImpl(
      _$FeedUserImpl _value, $Res Function(_$FeedUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = null,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$FeedUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedUserImpl implements _FeedUser {
  const _$FeedUserImpl(
      {required this.id,
      this.username = '',
      this.displayName = '',
      @JsonKey(name: 'avatar_url') this.avatarUrl});

  factory _$FeedUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedUserImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String username;
  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  @override
  String toString() {
    return 'FeedUser(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, username, displayName, avatarUrl);

  /// Create a copy of FeedUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedUserImplCopyWith<_$FeedUserImpl> get copyWith =>
      __$$FeedUserImplCopyWithImpl<_$FeedUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedUserImplToJson(
      this,
    );
  }
}

abstract class _FeedUser implements FeedUser {
  const factory _FeedUser(
      {required final String id,
      final String username,
      final String displayName,
      @JsonKey(name: 'avatar_url') final String? avatarUrl}) = _$FeedUserImpl;

  factory _FeedUser.fromJson(Map<String, dynamic> json) =
      _$FeedUserImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  String get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;

  /// Create a copy of FeedUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedUserImplCopyWith<_$FeedUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedItem _$FeedItemFromJson(Map<String, dynamic> json) {
  return _FeedItem.fromJson(json);
}

/// @nodoc
mixin _$FeedItem {
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  FeedUser get user => throw _privateConstructorUsedError;
  Track? get track => throw _privateConstructorUsedError;
  Story? get story => throw _privateConstructorUsedError;

  /// Serializes this FeedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedItemCopyWith<FeedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedItemCopyWith<$Res> {
  factory $FeedItemCopyWith(FeedItem value, $Res Function(FeedItem) then) =
      _$FeedItemCopyWithImpl<$Res, FeedItem>;
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      FeedUser user,
      Track? track,
      Story? story});

  $FeedUserCopyWith<$Res> get user;
  $TrackCopyWith<$Res>? get track;
  $StoryCopyWith<$Res>? get story;
}

/// @nodoc
class _$FeedItemCopyWithImpl<$Res, $Val extends FeedItem>
    implements $FeedItemCopyWith<$Res> {
  _$FeedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? createdAt = null,
    Object? user = null,
    Object? track = freezed,
    Object? story = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as FeedUser,
      track: freezed == track
          ? _value.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track?,
      story: freezed == story
          ? _value.story
          : story // ignore: cast_nullable_to_non_nullable
              as Story?,
    ) as $Val);
  }

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeedUserCopyWith<$Res> get user {
    return $FeedUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrackCopyWith<$Res>? get track {
    if (_value.track == null) {
      return null;
    }

    return $TrackCopyWith<$Res>(_value.track!, (value) {
      return _then(_value.copyWith(track: value) as $Val);
    });
  }

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StoryCopyWith<$Res>? get story {
    if (_value.story == null) {
      return null;
    }

    return $StoryCopyWith<$Res>(_value.story!, (value) {
      return _then(_value.copyWith(story: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedItemImplCopyWith<$Res>
    implements $FeedItemCopyWith<$Res> {
  factory _$$FeedItemImplCopyWith(
          _$FeedItemImpl value, $Res Function(_$FeedItemImpl) then) =
      __$$FeedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      @JsonKey(name: 'created_at') DateTime createdAt,
      FeedUser user,
      Track? track,
      Story? story});

  @override
  $FeedUserCopyWith<$Res> get user;
  @override
  $TrackCopyWith<$Res>? get track;
  @override
  $StoryCopyWith<$Res>? get story;
}

/// @nodoc
class __$$FeedItemImplCopyWithImpl<$Res>
    extends _$FeedItemCopyWithImpl<$Res, _$FeedItemImpl>
    implements _$$FeedItemImplCopyWith<$Res> {
  __$$FeedItemImplCopyWithImpl(
      _$FeedItemImpl _value, $Res Function(_$FeedItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? createdAt = null,
    Object? user = null,
    Object? track = freezed,
    Object? story = freezed,
  }) {
    return _then(_$FeedItemImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as FeedUser,
      track: freezed == track
          ? _value.track
          : track // ignore: cast_nullable_to_non_nullable
              as Track?,
      story: freezed == story
          ? _value.story
          : story // ignore: cast_nullable_to_non_nullable
              as Story?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedItemImpl implements _FeedItem {
  const _$FeedItemImpl(
      {required this.type,
      @JsonKey(name: 'created_at') required this.createdAt,
      required this.user,
      this.track,
      this.story});

  factory _$FeedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedItemImplFromJson(json);

  @override
  final String type;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final FeedUser user;
  @override
  final Track? track;
  @override
  final Story? story;

  @override
  String toString() {
    return 'FeedItem(type: $type, createdAt: $createdAt, user: $user, track: $track, story: $story)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedItemImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.track, track) || other.track == track) &&
            (identical(other.story, story) || other.story == story));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, createdAt, user, track, story);

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      __$$FeedItemImplCopyWithImpl<_$FeedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedItemImplToJson(
      this,
    );
  }
}

abstract class _FeedItem implements FeedItem {
  const factory _FeedItem(
      {required final String type,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      required final FeedUser user,
      final Track? track,
      final Story? story}) = _$FeedItemImpl;

  factory _FeedItem.fromJson(Map<String, dynamic> json) =
      _$FeedItemImpl.fromJson;

  @override
  String get type;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  FeedUser get user;
  @override
  Track? get track;
  @override
  Story? get story;

  /// Create a copy of FeedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedItemImplCopyWith<_$FeedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
