import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class Story with _$Story {
  const factory Story({
    required String id,
    required String trackId,
    required String authorUserId,
    required String lead,
    required String body,
    @Default(0) int likeCount,
    @Default(false) bool isLiked,
    required DateTime createdAt,
  }) = _Story;

  const Story._();

  factory Story.fromJson(Map<String, dynamic> json) => Story(
        id: json['id'] as String,
        trackId: json['track_id'] as String,
        authorUserId: json['author_user_id'] as String,
        lead: json['lead'] as String,
        body: json['body'] as String,
        likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'track_id': trackId,
        'author_user_id': authorUserId,
        'lead': lead,
        'body': body,
        'like_count': likeCount,
        'is_liked': isLiked,
        'created_at': createdAt.toIso8601String(),
      };
}
