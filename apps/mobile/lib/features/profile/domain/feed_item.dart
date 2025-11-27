// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../tracks/domain/track.dart';
import '../../story/domain/story.dart';

part 'feed_item.freezed.dart';
part 'feed_item.g.dart';

@freezed
class FeedUser with _$FeedUser {
  const factory FeedUser({
    required String id,
    required String username,
    required String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _FeedUser;

  factory FeedUser.fromJson(Map<String, dynamic> json) =>
      _$FeedUserFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String type,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required FeedUser user,
    Track? track,
    Story? story,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);
}

class FollowFeedPage {
  final List<FeedItem> items;
  final String? nextCursor;

  FollowFeedPage({
    required this.items,
    required this.nextCursor,
  });
}
