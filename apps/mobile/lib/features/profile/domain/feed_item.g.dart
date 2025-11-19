// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedUserImpl _$$FeedUserImplFromJson(Map<String, dynamic> json) =>
    _$FeedUserImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
    );

Map<String, dynamic> _$$FeedUserImplToJson(_$FeedUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
    };

_$FeedItemImpl _$$FeedItemImplFromJson(Map<String, dynamic> json) =>
    _$FeedItemImpl(
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      user: FeedUser.fromJson(json['user'] as Map<String, dynamic>),
      track: json['track'] == null
          ? null
          : Track.fromJson(json['track'] as Map<String, dynamic>),
      story: json['story'] == null
          ? null
          : Story.fromJson(json['story'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FeedItemImplToJson(_$FeedItemImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'user': instance.user,
      'track': instance.track,
      'story': instance.story,
    };
