// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Comment {
  String get id => throw _privateConstructorUsedError;
  String get authorUserId => throw _privateConstructorUsedError;
  String get authorDisplayName => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get targetType =>
      throw _privateConstructorUsedError; // "track" or "story"
  String get targetId => throw _privateConstructorUsedError;
  String? get parentCommentId => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get replyCount => throw _privateConstructorUsedError;
  List<Comment> get replies => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call(
      {String id,
      String authorUserId,
      String authorDisplayName,
      String body,
      DateTime createdAt,
      String targetType,
      String targetId,
      String? parentCommentId,
      int likeCount,
      int replyCount,
      List<Comment> replies});
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorUserId = null,
    Object? authorDisplayName = null,
    Object? body = null,
    Object? createdAt = null,
    Object? targetType = null,
    Object? targetId = null,
    Object? parentCommentId = freezed,
    Object? likeCount = null,
    Object? replyCount = null,
    Object? replies = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUserId: null == authorUserId
          ? _value.authorUserId
          : authorUserId // ignore: cast_nullable_to_non_nullable
              as String,
      authorDisplayName: null == authorDisplayName
          ? _value.authorDisplayName
          : authorDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
          _$CommentImpl value, $Res Function(_$CommentImpl) then) =
      __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String authorUserId,
      String authorDisplayName,
      String body,
      DateTime createdAt,
      String targetType,
      String targetId,
      String? parentCommentId,
      int likeCount,
      int replyCount,
      List<Comment> replies});
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
      _$CommentImpl _value, $Res Function(_$CommentImpl) _then)
      : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorUserId = null,
    Object? authorDisplayName = null,
    Object? body = null,
    Object? createdAt = null,
    Object? targetType = null,
    Object? targetId = null,
    Object? parentCommentId = freezed,
    Object? likeCount = null,
    Object? replyCount = null,
    Object? replies = null,
  }) {
    return _then(_$CommentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorUserId: null == authorUserId
          ? _value.authorUserId
          : authorUserId // ignore: cast_nullable_to_non_nullable
              as String,
      authorDisplayName: null == authorDisplayName
          ? _value.authorDisplayName
          : authorDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetType: null == targetType
          ? _value.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as String,
      targetId: null == targetId
          ? _value.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      parentCommentId: freezed == parentCommentId
          ? _value.parentCommentId
          : parentCommentId // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<Comment>,
    ));
  }
}

/// @nodoc

class _$CommentImpl implements _Comment {
  const _$CommentImpl(
      {required this.id,
      required this.authorUserId,
      required this.authorDisplayName,
      required this.body,
      required this.createdAt,
      required this.targetType,
      required this.targetId,
      this.parentCommentId,
      this.likeCount = 0,
      this.replyCount = 0,
      final List<Comment> replies = const []})
      : _replies = replies;

  @override
  final String id;
  @override
  final String authorUserId;
  @override
  final String authorDisplayName;
  @override
  final String body;
  @override
  final DateTime createdAt;
  @override
  final String targetType;
// "track" or "story"
  @override
  final String targetId;
  @override
  final String? parentCommentId;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int replyCount;
  final List<Comment> _replies;
  @override
  @JsonKey()
  List<Comment> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  String toString() {
    return 'Comment(id: $id, authorUserId: $authorUserId, authorDisplayName: $authorDisplayName, body: $body, createdAt: $createdAt, targetType: $targetType, targetId: $targetId, parentCommentId: $parentCommentId, likeCount: $likeCount, replyCount: $replyCount, replies: $replies)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorUserId, authorUserId) ||
                other.authorUserId == authorUserId) &&
            (identical(other.authorDisplayName, authorDisplayName) ||
                other.authorDisplayName == authorDisplayName) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.parentCommentId, parentCommentId) ||
                other.parentCommentId == parentCommentId) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            const DeepCollectionEquality().equals(other._replies, _replies));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      authorUserId,
      authorDisplayName,
      body,
      createdAt,
      targetType,
      targetId,
      parentCommentId,
      likeCount,
      replyCount,
      const DeepCollectionEquality().hash(_replies));

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);
}

abstract class _Comment implements Comment {
  const factory _Comment(
      {required final String id,
      required final String authorUserId,
      required final String authorDisplayName,
      required final String body,
      required final DateTime createdAt,
      required final String targetType,
      required final String targetId,
      final String? parentCommentId,
      final int likeCount,
      final int replyCount,
      final List<Comment> replies}) = _$CommentImpl;

  @override
  String get id;
  @override
  String get authorUserId;
  @override
  String get authorDisplayName;
  @override
  String get body;
  @override
  DateTime get createdAt;
  @override
  String get targetType; // "track" or "story"
  @override
  String get targetId;
  @override
  String? get parentCommentId;
  @override
  int get likeCount;
  @override
  int get replyCount;
  @override
  List<Comment> get replies;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
