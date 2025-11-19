import 'package:freezed_annotation/freezed_annotation.dart';
import '../../tracks/domain/track.dart';
import '../../story/domain/story.dart';

part 'feed_item.freezed.dart';
part 'feed_item.g.dart';

@freezed
class FeedUser with _$FeedUser {
  const factory FeedUser({
    required String id,
    required String displayName,
  }) = _FeedUser;

  factory FeedUser.fromJson(Map<String, dynamic> json) =>
      _$FeedUserFromJson(json);
}

@freezed
class FeedItem with _$FeedItem {
  const factory FeedItem({
    required String type,
    required DateTime createdAt,
    required FeedUser user,
    Track? track,
    Story? story,
  }) = _FeedItem;

  factory FeedItem.fromJson(Map<String, dynamic> json) =>
      _$FeedItemFromJson(json);
}
