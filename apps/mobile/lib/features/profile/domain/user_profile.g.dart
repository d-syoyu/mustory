// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      linkUrl: json['link_url'] as String?,
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      storyCount: (json['storyCount'] as num?)?.toInt() ?? 0,
      followerCount: (json['followerCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isFollowedByMe: json['isFollowedByMe'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
      'email': instance.email,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'location': instance.location,
      'link_url': instance.linkUrl,
      'trackCount': instance.trackCount,
      'storyCount': instance.storyCount,
      'followerCount': instance.followerCount,
      'followingCount': instance.followingCount,
      'isFollowedByMe': instance.isFollowedByMe,
    };

_$UserSummaryImpl _$$UserSummaryImplFromJson(Map<String, dynamic> json) =>
    _$UserSummaryImpl(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$UserSummaryImplToJson(_$UserSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'email': instance.email,
    };
