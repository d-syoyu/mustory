import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String authorUserId,
    required String authorDisplayName,
    required String body,
    required DateTime createdAt,
    required String targetType, // "track" or "story"
    required String targetId,
    String? parentCommentId,
    @Default(0) int likeCount,
    @Default(0) int replyCount,
    @Default(false) bool isLiked,
    @Default(<Comment>[]) List<Comment> replies,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json['id'] as String? ?? '',
        authorUserId: json['author_user_id'] as String? ?? '',
        authorDisplayName: json['author_display_name'] as String? ?? '',
        body: json['body'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        targetType: json['target_type'] as String? ?? '',
        targetId: json['target_id'] as String? ?? '',
        parentCommentId: json['parent_comment_id'] as String?,
        likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
        replyCount: (json['reply_count'] as num?)?.toInt() ?? 0,
        isLiked: (json['is_liked'] as bool?) ?? false,
        replies: [],
      );
}
