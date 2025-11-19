// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StoryImpl _$$StoryImplFromJson(Map<String, dynamic> json) => _$StoryImpl(
      id: json['id'] as String,
      trackId: json['trackId'] as String,
      authorUserId: json['authorUserId'] as String,
      lead: json['lead'] as String,
      body: json['body'] as String,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StoryImplToJson(_$StoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackId': instance.trackId,
      'authorUserId': instance.authorUserId,
      'lead': instance.lead,
      'body': instance.body,
      'likeCount': instance.likeCount,
      'createdAt': instance.createdAt.toIso8601String(),
    };
